package it.sella.anagrafe.dai;

import it.sella.anagrafe.AnagrafeDAIException;
import it.sella.anagrafe.CollegamentoView;
import it.sella.anagrafe.DAIConfigException;
import it.sella.anagrafe.DAIConfigView;
import it.sella.anagrafe.GestoreAnagrafeException;
import it.sella.anagrafe.GestoreAnagrafeFactory;
import it.sella.anagrafe.GestoreAttributiEsterniException;
import it.sella.anagrafe.GestoreCollegamentoException;
import it.sella.anagrafe.IDAIConfigView;
import it.sella.anagrafe.IDAIRegoleDetailsView;
import it.sella.anagrafe.IGestoreAnagrafe;
import it.sella.anagrafe.SoggettoDAIDataView;
import it.sella.anagrafe.az.ICollegatiAbilAziendaView;
import it.sella.anagrafe.dbaccess.dai.DAIConfigGetterHelper;
import it.sella.anagrafe.dbaccess.dai.DAIDBAccessHelper;
import it.sella.anagrafe.factory.AnagrafeDAIFactory;
import it.sella.anagrafe.factory.FactoryException;
import it.sella.anagrafe.predicate.PredicateImplimentation;
import it.sella.anagrafe.predicate.PredicateUtil;
import it.sella.anagrafe.util.ARQuestinarioDAIHandler;
import it.sella.anagrafe.util.AnagConfigurationHandler;
import it.sella.anagrafe.view.AziendaView;
import it.sella.anagrafe.view.ICollegateView;
import it.sella.anagrafe.view.PersonaFisicaView;
import it.sella.anagrafe.view.PlurintestazioneView;
import it.sella.anagrafe.view.SoggettoView;
import it.sella.util.Log4Debug;
import it.sella.util.Log4DebugFactory;

import java.rmi.RemoteException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

/**
 * @author GBS03447
 * 
 */
public class DaiRegoleSoggettohelper {

	private static final Log4Debug log4Debug = Log4DebugFactory.getLog4Debug(DaiRegoleSoggettohelper.class);
	private static final String DAIOK = "DAIOK";
	private static final String DAIALERT = "DAIALERT";
	private static final String DAIKO = "DAIKO";

	/**
	 * This Method Process the Regole Data Based on validations and returns the Regole Details Collection
	 * 
	 * @param soggettoView
	 * @param tipoSoggetto
	 * @throws AnagrafeDAIException
	 */
	public Collection<IDAIRegoleDetailsView> processDaiRegoleData(final SoggettoView soggettoView, final String tipoSoggetto) throws AnagrafeDAIException {
		final Collection<IDAIRegoleDetailsView> regoleFinalList = new ArrayList<IDAIRegoleDetailsView>();
		try {
			final Map<String, Collection<IDAIConfigView>> compatDAICodesGroup = new DAIDBAccessHelper().getCompatibleDAICodesWithGroup(tipoSoggetto);
			if(compatDAICodesGroup != null && !compatDAICodesGroup.isEmpty()) {
				final Iterator<Entry<String, Collection<IDAIConfigView>>> iterator = compatDAICodesGroup.entrySet().iterator();
				while (iterator.hasNext()) {
					final Entry<String, Collection<IDAIConfigView>> entry = iterator.next();
					final String daiDatiType = entry.getKey();
					final Collection<IDAIConfigView> daiReoleCodeList = entry.getValue();
					log4Debug.debug("processDaiRegoleData   ============  daiDatiType ===============  ", daiDatiType);
					log4Debug.debug("processDaiRegoleData   ============  daiReoleCodeList ===============  ", daiReoleCodeList);
					if (DaiDatiTypes.contains(daiDatiType)) {
						final Collection<IDAIRegoleDetailsView> regoleViewList = DaiDatiTypes.valueOf(daiDatiType).processDaiCalculation(daiReoleCodeList, soggettoView);
						if (regoleViewList != null) {
							regoleFinalList.addAll(regoleViewList);
						}
					}
				}
			}
			log4Debug.debug("processDaiRegoleData   ============  regoleFinalList  Size ===============  ", regoleFinalList.size());
		} catch (final DAIConfigException e) {
			log4Debug.debugStackTrace(e);
			throw new AnagrafeDAIException(e.getMessage(), e);
		}
		return regoleFinalList;
	}

	/**
	 * Sort the Regole List Based on ID in Ascending order.
	 * check Any Regole Weightage is KO / Alert. if none is KO / alert .. set
	 * DAIAnagrafico is IS ok ELSE the first KO or alert entry need to consider
	 * for dai soggetto
	 * 
	 * @param regoleFinalList
	 * @throws AnagrafeDAIException
	 */
	public SoggettoDAIDataView calculateDaiFromRegoleData(final Collection<IDAIRegoleDetailsView> regoleFinalList) throws AnagrafeDAIException {
		SoggettoDAIDataView daiView = null;
		if (regoleFinalList != null && !regoleFinalList.isEmpty()) {
			
			Collections.sort((List)regoleFinalList, new Comparator<IDAIRegoleDetailsView>() {
				public int compare(final IDAIRegoleDetailsView view1, final IDAIRegoleDetailsView view2) {
					return (view1.getId()).compareTo(view2.getId());
				}
			});
			
			daiView = new SoggettoDAIDataView();
			final Collection<IDAIRegoleDetailsView> daiKOCollection = PredicateImplimentation.filter(regoleFinalList, PredicateUtil.daiWeightageExist(DAIKO));
			log4Debug.debug("calculateDaiFromRegoleData  =============   daiKOCollection  Size ===========  ", dataNotNullGetSize(daiKOCollection));
			
			final Collection<IDAIRegoleDetailsView> daiAlertCollection = PredicateImplimentation.filter(regoleFinalList,PredicateUtil.daiWeightageExist(DAIALERT));
			log4Debug.debug("calculateDaiFromRegoleData  =============  daiAlertCollection Size ============= ", dataNotNullGetSize(daiAlertCollection));
			
			if (daiKOCollection != null && !daiKOCollection.isEmpty()) {
				daiView = setDaiSoggettoView(daiKOCollection);
			} else if (daiAlertCollection != null && !daiAlertCollection.isEmpty()) {
				daiView = setDaiSoggettoView(daiAlertCollection);
			} else {
				daiView = setDaiSoggettoView(regoleFinalList);
			}
		}
		return daiView;
	}

	/**
	 * This Method Gets DAI Anagarfe of Linked Soggetto's and If any of the Linked Subject has DAI KO then LINKED DAI will be DAIKO else DAI OK.
	 * This Used for LINKED DAI Calculation for PF Subjects .. both Application and API.
	 * @param collegateViews
	 * @return
	 * @throws AnagrafeDAIException
	 */
	public String getCollegateSubjectsDAIStatus(final Collection collegateViews) throws AnagrafeDAIException {
		String daiStatus = DAIOK;
		if (collegateViews != null && !collegateViews.isEmpty()) {
			for (final Object object : collegateViews) {
				final ICollegateView collegatePFView = (ICollegateView) object;
				final Long linkedSoggettoId = collegatePFView.getId();
				final String typeOfCollegate = collegatePFView.getTypeOfCollegate();
				if (linkedSoggettoId != null && !"ABIL8CIFRE".equalsIgnoreCase(typeOfCollegate)) {
					final SoggettoDAIDataView daiSoggettoView = new DAIDBAccessHelper().getDAISoggettoView(linkedSoggettoId);
					final String daiStatusCode = getDAIStatusCode(daiSoggettoView);
					if (DAIKO.equals(daiStatusCode)) {
						daiStatus = DAIKO;
						break;
					}
				}
			}
		}
		log4Debug.debug("getCollegateSubjectsDAIStatus  ===============  DAI ANAGRAFE  ========   ", daiStatus);
		return daiStatus;
	}

	/**
	 * This Mesthod gets the DAISoggetto data of Intestario Soggettos .. 
	 * If any one Intestario Subject has DAI Anagrafe or AR DAI as DAIKO .. output will return as DAIKO else DAIOK
	 * @param soggettoIds
	 * @param arDAIConfigAllowed
	 * @return
	 * @throws AnagrafeDAIException
	 */
	public String getPLIntestarioDAIStatus(final Collection soggettoIds, final Boolean arDAIConfigAllowed) throws AnagrafeDAIException {
		String daiStatus = DAIOK;
		if (soggettoIds != null && !soggettoIds.isEmpty()) {
			for (final Object object : soggettoIds) {
				final Long linkedSoggettoId = object instanceof CollegamentoView ? ((CollegamentoView) object).getLinkedSoggettoId() : (Long) object;
				if (linkedSoggettoId != null) {
					log4Debug.debug("calculateDAIForPLSoggetto ===========  Linked soggetto Id  ========  ", linkedSoggettoId);
					final SoggettoDAIDataView daiSoggettoView = new DAIDBAccessHelper().getDAISoggettoView(linkedSoggettoId);
					final String daiStatusCode = getDAIStatusCode(daiSoggettoView);
					final String arQuestionarioDAI = getARQuestionarioDAIAVForSoggetto(linkedSoggettoId, arDAIConfigAllowed);
					log4Debug.debug("calculateDAIForPLSoggetto ===========  Linked soggetto Id  DAI ANAGRAFE ========  ", daiStatusCode);
					log4Debug.debug("calculateDAIForPLSoggetto ===========  Linked soggetto Id  AR DAI  ========  ", arQuestionarioDAI);
					if (DAIKO.equals(daiStatusCode) || DAIKO.equals(arQuestionarioDAI)) {
						daiStatus = DAIKO;
						break;
					}
				}
			}
		}
		return daiStatus;
	}

	/**
	 * calculating DAI Regole Data For AZ.
	 * @param aziendaView
	 * @throws AnagrafeDAIException
	 */
	public void setDaiRegoleData(final AziendaView aziendaView) throws AnagrafeDAIException {
		final Boolean oldDAISwitchAllowed = isDAISwitchConfigurationAllowed();
		aziendaView.setDaiSwitchAllowed(oldDAISwitchAllowed);
		final Boolean newDAIConfigAllowed = isNewDAIConfigAllowedForLoginBank();
		aziendaView.setNewDAIConfigAllowed(newDAIConfigAllowed);
		if(newDAIConfigAllowed) {
			aziendaView.setArDAIConfigAllowed(isARDAIConfigAllowedForLoginBank());
			final Collection<IDAIRegoleDetailsView> daiRegoleData = processDaiRegoleData(aziendaView, "AZIENDE");
			aziendaView.setDaiRegoleView(daiRegoleData);
		}
	}

	/**
	 * Used in Application For DAI Soggetto and Final attributi DAi.
	 * For Azienda Subject Linked PF DAI not Considering in DAI Calulation for censimento and Varia. Linked DAI calculation Commented below..
	 * @param aziendaView
	 * @throws AnagrafeDAIException
	 * @throws FactoryException
	 */
	public void calculateDAISoggettoForAZ(final AziendaView aziendaView) throws FactoryException {
		final Collection<IDAIRegoleDetailsView> daiRegoleData = aziendaView.getDaiRegoleView();
		final Long soggettoId = aziendaView.getId();

		try {
			final SoggettoDAIDataView daiSoggetto = calculateDaiFromRegoleData(daiRegoleData);
			aziendaView.setDaiSoggettoView(daiSoggetto);
			final String daiStatusCodeNew = getDAIStatusCode(daiSoggetto);
			Boolean finalDaiValue = Boolean.TRUE;
			//String collegateDAISoggetto = null;
			
			log4Debug.debug("calculateDAISoggettoForAZ  ===============  soggettoId  =====   ", soggettoId);
			
			final String daiFromARQuestinario = getARQuestionarioDAIAVForSoggetto(soggettoId, aziendaView.isArDAIConfigAllowed());
			//collegateDAISoggetto = getCollegateSubjectsDAIStatus(aziendaView.getCollegateViews());
			
			if((DAIOK.equals(daiStatusCodeNew) || DAIALERT.equals(daiStatusCodeNew)) && (daiFromARQuestinario == null || DAIOK.equals(daiFromARQuestinario) || DAIALERT.equals(daiFromARQuestinario)) /*&& (DAIOK.equals(collegateDAISoggetto) || DAIALERT.equals(collegateDAISoggetto))*/) {
				finalDaiValue = Boolean.FALSE;
			}
			log4Debug.debug("calculateDAISoggettoForAZ  ===============  DAI Anagrafe  =====   ", daiStatusCodeNew);
			log4Debug.debug("calculateDAISoggettoForAZ  ===============  AR DAI   =====   ", daiFromARQuestinario);
			//log4Debug.debug("calculateDAISoggettoForAZ  ===============  LINKED DAI =====   ", collegateDAISoggetto);
			log4Debug.debug("calculateDAISoggettoForAZ  ===============  Final Attributi DAI =====   ", finalDaiValue);
			
			setDAIValueInAttributiView(aziendaView, finalDaiValue);
			
			//aziendaView.setLinkedSoggettosDAI(collegateDAISoggetto);
			aziendaView.setArQuestionarioDAI(daiFromARQuestinario);
		} catch (final AnagrafeDAIException e) {
			log4Debug.debugStackTrace(e);
			throw new FactoryException(e.getMessage());
		}
	}

	/**
	 * DAI Regole calculation Call for PF
	 * @param personaFisicaView
	 * @throws AnagrafeDAIException
	 */
	public void setDaiRegoleData(final PersonaFisicaView personaFisicaView) throws AnagrafeDAIException {
		final Boolean oldDAISwitchAllowed = isDAISwitchConfigurationAllowed();
		personaFisicaView.setDaiSwitchAllowed(oldDAISwitchAllowed);
		final Boolean newDAIConfigAllowed = isNewDAIConfigAllowedForLoginBank();
		personaFisicaView.setNewDAIConfigAllowed(newDAIConfigAllowed);
		if(newDAIConfigAllowed) {
			personaFisicaView.setArDAIConfigAllowed(isARDAIConfigAllowedForLoginBank());
			final Collection<IDAIRegoleDetailsView> daiRegoleData = processDaiRegoleData(personaFisicaView, "Semplice");
			personaFisicaView.setDaiRegoleView(daiRegoleData);
		}
	}

	/**
	 * Used in Application For DAI Soggetto and Final attributi DAi
	 * @param personaFisicaView
	 * @throws FactoryException
	 */
	public void calculateDAISoggettoForPF(final PersonaFisicaView personaFisicaView) throws FactoryException {
		final Collection<IDAIRegoleDetailsView> daiRegoleData = personaFisicaView.getDaiRegoleView();
		final Long soggettoId = personaFisicaView.getId();
		try {
			final SoggettoDAIDataView daiSoggetto = calculateDaiFromRegoleData(daiRegoleData);
			personaFisicaView.setDaiSoggettoView(daiSoggetto);
			final String daiStatusCodeNew = getDAIStatusCode(daiSoggetto);			
			Boolean finalDaiValue = Boolean.TRUE;
			
			log4Debug.debug("calculateDAISoggettoForPF  ===============  soggettoId =====   ", soggettoId);
			
			final String daiFromARQuestinario = getARQuestionarioDAIAVForSoggetto(soggettoId, personaFisicaView.isArDAIConfigAllowed());
			final String collegateDAISoggetto = getCollegateSubjectsDAIStatus(personaFisicaView.getCollegateViews());
			
			if((DAIOK.equals(daiStatusCodeNew) || DAIALERT.equals(daiStatusCodeNew)) && (daiFromARQuestinario == null || DAIOK.equals(daiFromARQuestinario) || DAIALERT.equals(daiFromARQuestinario)) && (DAIOK.equals(collegateDAISoggetto) || DAIALERT.equals(collegateDAISoggetto))) {
				finalDaiValue = Boolean.FALSE;
			}
			log4Debug.debug("calculateDAISoggettoForPF  ===============  DAI Anagrafe =====   ", daiStatusCodeNew);
			log4Debug.debug("calculateDAISoggettoForPF  ===============  LINKED DAI =====   ", collegateDAISoggetto);
			log4Debug.debug("calculateDAISoggettoForPF  ===============  AR DAI   =====   ", daiFromARQuestinario);
			log4Debug.debug("calculateDAISoggettoForPF  ===============  Final Attributi DAI  =====   ", finalDaiValue);
			
			setDAIValueInAttributiView(personaFisicaView, finalDaiValue);
			
			personaFisicaView.setLinkedSoggettosDAI(collegateDAISoggetto);
			personaFisicaView.setArQuestionarioDAI(daiFromARQuestinario);
		} catch (final AnagrafeDAIException e) {
			log4Debug.debugStackTrace(e);
			throw new FactoryException(e.getMessage());
		}
	}
	
	/**
	 * Used in Application For Final attributi DAi Calculation For PL.
	 * Get DAI anagrafe and AR DAI Of PL Intestatrio.. and Calculate Final DAi
	 * @param plurintestazioneView
	 * @throws FactoryException
	 */
	public void calculateNewAttributiDAIForPL(final PlurintestazioneView plurintestazioneView) throws FactoryException {
		final Boolean newDAIConfigAllowed = isNewDAIConfigAllowedForLoginBank();
        plurintestazioneView.setNewDAIConfigAllowed(newDAIConfigAllowed);
        final Boolean arDAIConfigAllowed = isARDAIConfigAllowedForLoginBank();
    	plurintestazioneView.setArDAIConfigAllowed(arDAIConfigAllowed);
    	plurintestazioneView.setDaiSwitchAllowed(isDAISwitchConfigurationAllowed());
    	
        if(newDAIConfigAllowed) {
        	Boolean finalDaiValue = Boolean.TRUE;
    		final Collection soggettoIds = plurintestazioneView.getSoggettoIds();
    		try {
    			String plIntestarioDAIStatus = null;
    			plIntestarioDAIStatus = getPLIntestarioDAIStatus(soggettoIds, arDAIConfigAllowed);
    				
    			if(DAIOK.equals(plIntestarioDAIStatus) || DAIALERT.equals(plIntestarioDAIStatus)) {
    				finalDaiValue = Boolean.FALSE;
    			}
    			log4Debug.debug("calculateNewAttributiDAIForPL  ======   plIntestarioDAIStatus  =======  ",plIntestarioDAIStatus);
    			log4Debug.debug("calculateNewAttributiDAIForPL  ======   finalDaiValue  =======  ",finalDaiValue);
    			
    			setDAIValueInAttributiView(plurintestazioneView, finalDaiValue);
    			
    			plurintestazioneView.setIntestariosDAI(plIntestarioDAIStatus);
    		} catch (final AnagrafeDAIException e) {
    			log4Debug.debugStackTrace(e);
    			throw new FactoryException(e.getMessage());
    		} 
        }
	}

	/**
	 * Returns the First Regole DataWeightage As SoggettoDAIDataView from Regole List.
	 * @param daiCollection
	 * @param daiView
	 * @param daiOk
	 * @throws AnagrafeDAIException
	 */
	private SoggettoDAIDataView setDaiSoggettoView(final Collection<IDAIRegoleDetailsView> daiCollection) throws AnagrafeDAIException {
		log4Debug.debug("setDaiSoggettoView  ============== daiCollection  ==========  ", daiCollection != null ? daiCollection.size() : "NULL");
		final SoggettoDAIDataView daiView = new SoggettoDAIDataView();
		if (daiCollection != null && !daiCollection.isEmpty()) {
			for (final IDAIRegoleDetailsView daiRegoleDetailView : daiCollection) {
				daiView.setDaiRegoleData(daiRegoleDetailView);
				daiView.setDaiWeightId(daiRegoleDetailView.getDaiWeight());
				log4Debug.debug("setDaiSoggettoView  ============== DaiWeight ==========  ", daiRegoleDetailView.getDaiWeight());
				break;
			}
		}
		return daiView;
	}

	/**
	 * By Passing PF SoggettoId (has DAI changed from KO to Ok) .. will get the AZ principle SoggettoId (PF is linked to AZ).. 
	 * For the AZ ..Get All the Linked soggettoId's and get the DAI for all Linked PF ..If All DAI OK then Update the DAI Attributi For AZ Soggetto as true.
	 * Used For Both application and Java API
	 * @param soggettoIdPf
	 * @throws RemoteException
	 * @throws AnagrafeDAIException
	 */
	public void updateDAIForPrincipleSoggettoAZ(final Long soggettoIdPf, final Long opId, final Boolean daiSwitchAllowed) throws RemoteException, AnagrafeDAIException {
		final IGestoreAnagrafe gestoreAnagrafe = GestoreAnagrafeFactory.getInstance().getGestoreAnagrafe();

		try {
			final Collection<ICollegatiAbilAziendaView> collegatiAbilAzienda = gestoreAnagrafe.getCollegatiAbilAzienda(soggettoIdPf);
			if (collegatiAbilAzienda != null && !collegatiAbilAzienda.isEmpty()) {
				for (final ICollegatiAbilAziendaView collegatiAbilAziendaView : collegatiAbilAzienda) {
					final Long principleSoggettoId = collegatiAbilAziendaView.getSoggetto();
					log4Debug.debug("updateDAIForPrincipleSoggettoAZ  ============ principleSoggettoId  ========== ",principleSoggettoId);
					if (principleSoggettoId != null) {
						final SoggettoDAIDataView daiSoggettoView = new DAIDBAccessHelper().getDAISoggettoView(principleSoggettoId);
						final String daiStatusCode = getDAIStatusCode(daiSoggettoView);
						final String attributiDAI = gestoreAnagrafe.getAttribuiEsterniValore(principleSoggettoId, getDaiCausale(daiSwitchAllowed));
						if ((attributiDAI == null || "true".equals(attributiDAI)) && (DAIOK.equals(daiStatusCode) || DAIALERT.equals(daiStatusCode))) {
							final Collection soggettiCollegatiAbilitati = gestoreAnagrafe.getSoggettiCollegatiAbilitati(principleSoggettoId);
							if (soggettiCollegatiAbilitati != null && !soggettiCollegatiAbilitati.isEmpty()) {
								soggettiCollegatiAbilitati.remove(soggettoIdPf);
								final String daiStatusForListOfSoggetto = getDAIStatusForLinkedSoggettoOfAZ(soggettiCollegatiAbilitati);
								if (DAIOK.equals(daiStatusForListOfSoggetto)) {
									new AnagrafeDAIFactory().setAttributiDAIForSoggetto(principleSoggettoId, false, daiSwitchAllowed, opId);
								}
							}
						}
					}
				}
			}
		} catch (final GestoreAnagrafeException e) {
			log4Debug.debugStackTrace(e);
			throw new AnagrafeDAIException(e.getMessage(), e);
		} catch (final FactoryException e) {
			log4Debug.debugStackTrace(e);
			throw new AnagrafeDAIException(e.getMessage(), e);
		}
	}

	/**
	 * By Passing PF SoggettoId (has DAI changed from KO to Ok) .. will get the PL principle SoggettoId (PF is linked to PL).. 
	 * Get all the Linked PF INTST fro PL .. and check For all the Linked Soggetto Has DAI as OK .. then update daiAttributi as false.
	 * Used For Both application and Java API
	 * @param soggettoIdPf
	 * @param opId
	 * @param arDAIConfigAllowed
	 * @throws RemoteException
	 * @throws AnagrafeDAIException
	 */
	public Collection<Long> updateDAIForPrincipleSoggettoPL(final Long soggettoIdPf, final Long opId, final Boolean arDAIConfigAllowed, final Boolean daiSwitchAllowed) throws RemoteException, AnagrafeDAIException {
		final IGestoreAnagrafe gestoreAnagrafe = GestoreAnagrafeFactory.getInstance().getGestoreAnagrafe();
		final Collection<Long> plSoggetto = new ArrayList<Long>();
		try {
			final Collection soggettoPrincipale = gestoreAnagrafe.getSoggettoPrincipale(soggettoIdPf, "INTST");
			if (soggettoPrincipale != null && !soggettoPrincipale.isEmpty()) {
				for (final Object object : soggettoPrincipale) {
					final Long pLsoggettoId = (Long) object;
					log4Debug.debug("updateDAIForPrincipleSoggettoPL  ============ pLsoggettoId  ========== ",pLsoggettoId);
					final String attributiDAI = gestoreAnagrafe.getAttribuiEsterniValore(pLsoggettoId, getDaiCausale(daiSwitchAllowed));
					if (attributiDAI == null || "true".equals(attributiDAI)) {
						final Collection soggettiCollegatiAbilitati = gestoreAnagrafe.getSoggettiCollegatiAbilitati(pLsoggettoId);
						if (soggettiCollegatiAbilitati != null && !soggettiCollegatiAbilitati.isEmpty()) {
							final String daiStatusForListOfSoggetto = getDAIStatusForIntestarioOfPL(soggettiCollegatiAbilitati, arDAIConfigAllowed, soggettoIdPf);
							if (DAIOK.equals(daiStatusForListOfSoggetto)) {
								new AnagrafeDAIFactory().setAttributiDAIForSoggetto(pLsoggettoId, false, daiSwitchAllowed, opId);
								plSoggetto.add(pLsoggettoId);
							}
						}
					}
				}
			}
		} catch (final GestoreCollegamentoException e) {
			log4Debug.debugStackTrace(e);
			throw new AnagrafeDAIException(e.getMessage(), e);
		} catch (final GestoreAttributiEsterniException e) {
			log4Debug.debugStackTrace(e);
			throw new AnagrafeDAIException(e.getMessage(), e);
		} catch (final FactoryException e) {
			log4Debug.debugStackTrace(e);
			throw new AnagrafeDAIException(e.getMessage(), e);
		}
		return plSoggetto;
	}

	/**
	 * Gets The DAISoggetto Status For Intestario Linked to PL.
	 * If any Linked subject has DAI Anagrafe as DAIKO or AR DAI is KO .. the output will be DAIKO .. else DAIOK
	 * @param soggettiCollegatiAbilitati
	 * @param arDAIConfigAllowed
	 * @return
	 * @throws AnagrafeDAIException
	 */
	private String getDAIStatusForIntestarioOfPL(final Collection soggettiCollegatiAbilitati, final Boolean arDAIConfigAllowed, final Long soggettoIdPf) throws AnagrafeDAIException {
		String daiStatus = DAIOK;
		if (soggettiCollegatiAbilitati != null && !soggettiCollegatiAbilitati.isEmpty()) {
			for (final Object object : soggettiCollegatiAbilitati) {
				final Long soggettoId = (Long) object;
				final SoggettoDAIDataView daiSoggettoView = new DAIDBAccessHelper().getDAISoggettoView(soggettoId);
				final String daiStatusCode = soggettoIdPf.equals(soggettoId) ? "DAIOK" : getDAIStatusCode(daiSoggettoView);
				final String daiFromARQuestinario = getARQuestionarioDAIAVForSoggetto(soggettoId, arDAIConfigAllowed);
				if (DAIKO.equals(daiStatusCode) || DAIKO.equals(daiFromARQuestinario)) {
					daiStatus = DAIKO;
					break;
				}
			}
		}
		log4Debug.debug("getDAIStatusForIntestarioOfPL  ===============  daiStatus  ========   ", daiStatus);
		return daiStatus;
	}
	
	/**
	 * @param daiSoggettoView
	 * @return
	 */
	public String getDAIStatusCode(final SoggettoDAIDataView daiSoggettoView) {
		String weightage = null;
		if (daiSoggettoView != null && daiSoggettoView.getDaiWeightId() != null) {
			weightage = daiSoggettoView.getDaiWeightId().getDaiConfigCode();
		}
		return weightage;
	}
	
	/**
	 * Gets The DAISoggetto Status For Collegates Linked to AZ
	 * If any Linked subject has DAIKO .. the output will be DAIKO .. else DAIOK
	 * @param soggettiCollegatiAbilitati
	 * @return
	 * @throws AnagrafeDAIException
	 */
	private String getDAIStatusForLinkedSoggettoOfAZ(final Collection soggettiCollegatiAbilitati) throws AnagrafeDAIException {
		String daiStatus = DAIOK;
		if (soggettiCollegatiAbilitati != null && !soggettiCollegatiAbilitati.isEmpty()) {
			for (final Object object : soggettiCollegatiAbilitati) {
				final Long soggettoId = (Long) object;
				final SoggettoDAIDataView daiSoggettoView = new DAIDBAccessHelper().getDAISoggettoView(soggettoId);
				final String daiStatusCode = getDAIStatusCode(daiSoggettoView);
				if (DAIKO.equals(daiStatusCode)) {
					daiStatus = DAIKO;
					break;
				}
			}
		}
		log4Debug.debug("getDAIStatusForLinkedSoggettoOfAZ  ===============  daiStatus  ========   ", daiStatus);
		return daiStatus;
	}
	
	public Boolean isNewDAIConfigAllowedForLoginBank () {
		return AnagConfigurationHandler.isConfigurationAllowed("NewDaiAllowed");
	}
	
	private int dataNotNullGetSize(final Collection dataCollection) {
		return dataCollection != null ? dataCollection.size() : 0;
	}
	
	private Boolean isARDAIConfigAllowedForLoginBank () {
		return AnagConfigurationHandler.isConfigurationAllowed("ARDaiAllowed");
	}
	
	/**
	 * @param soggettoId
	 * @param arDAIConfigAllowed
	 * @return
	 */
	public String getARQuestionarioDAIAVForSoggetto (final Long soggettoId, final Boolean arDAIConfigAllowed) {
		String arQuestionarioDAI = null;
		if(arDAIConfigAllowed != null && arDAIConfigAllowed) {
			arQuestionarioDAI = ARQuestinarioDAIHandler.getARQuestionarioDAIAVForSoggetto(soggettoId);
		}
		return arQuestionarioDAI;
	}
	
	/**
	 * @return
	 */
	private Boolean isDAISwitchConfigurationAllowed() {
		return AnagConfigurationHandler.isConfigurationAllowed("DAISwitch");
	}
	
	/**
	 * @param aziendaView
	 * @param daiValue
	 */
	private void setDAIValueInAttributiView(final AziendaView aziendaView, final Boolean daiValue) {
		if (aziendaView.getAttributiEsterniAZView() != null) {
			if(aziendaView.getDaiSwitchAllowed() != null && aziendaView.getDaiSwitchAllowed()) {
				aziendaView.getAttributiEsterniAZView().setDai(daiValue);
			}else {
				aziendaView.getAttributiEsterniAZView().setNewDai(daiValue);
			}
		}
	}
	
	/**
	 * @param personaFisicaView
	 * @param daiValue
	 */
	private void setDAIValueInAttributiView( final PersonaFisicaView personaFisicaView, final Boolean daiValue) {
		if (personaFisicaView.getAttributiEsterniPFView() != null) {
			if (personaFisicaView.getDaiSwitchAllowed() != null && personaFisicaView.getDaiSwitchAllowed()) {
				personaFisicaView.getAttributiEsterniPFView().setDai(daiValue);
			} else {
				personaFisicaView.getAttributiEsterniPFView().setNewDai(daiValue);
			}
		}
	}
	
	/**
	 * @param plurintestazioneView
	 * @param daiValue
	 */
	private void setDAIValueInAttributiView( final PlurintestazioneView plurintestazioneView, final Boolean daiValue) {
		if (plurintestazioneView.getAttributiEsterniPLView() != null) {
			if(plurintestazioneView.getDaiSwitchAllowed() != null && plurintestazioneView.getDaiSwitchAllowed()) {
				plurintestazioneView.getAttributiEsterniPLView().setDai(daiValue);
			}else {
				plurintestazioneView.getAttributiEsterniPLView().setNewDai(daiValue);
			}
		}
	}
	
	private String getDaiCausale (final Boolean daiSwitchAllowed) {
		return (daiSwitchAllowed != null && daiSwitchAllowed) ? "dai" : "newDai";
	}
	
	/**
	 * @param regoleFinalList
	 * @return
	 * @throws AnagrafeDAIException
	 */
	public SoggettoDAIDataView calculateDaiFromRegoleDataWIthOutSort(final Collection<IDAIRegoleDetailsView> regoleFinalList) throws AnagrafeDAIException {
		SoggettoDAIDataView daiView = null;
		if (regoleFinalList != null && !regoleFinalList.isEmpty()) {
			daiView = new SoggettoDAIDataView();
			final Collection<IDAIRegoleDetailsView> daiKOCollection = PredicateImplimentation.filter(regoleFinalList, PredicateUtil.daiWeightageExist(DAIKO));
			log4Debug.debug("calculateDaiFromRegoleData  =============   daiKOCollection  Size ===========  ", dataNotNullGetSize(daiKOCollection));
			
			final Collection<IDAIRegoleDetailsView> daiAlertCollection = PredicateImplimentation.filter(regoleFinalList,PredicateUtil.daiWeightageExist(DAIALERT));
			log4Debug.debug("calculateDaiFromRegoleData  =============  daiAlertCollection Size ============= ", dataNotNullGetSize(daiAlertCollection));
			
			if (daiKOCollection != null && !daiKOCollection.isEmpty()) {
				daiView = setDaiSoggettoView(daiKOCollection);
			} else if (daiAlertCollection != null && !daiAlertCollection.isEmpty()) {
				daiView = setDaiSoggettoView(daiAlertCollection);
			} else {
				daiView = setDaiSoggettoView(regoleFinalList);
			}
		}
		return daiView;
	}
	
	/**
	 * @param daiStatusCode
	 * @return
	 * @throws DAIConfigException
	 */
	public String getDAIStatusDescription(final String daiStatusCode) throws DAIConfigException {
		String daiStatusDesc = null;
		final DAIConfigGetterHelper daiConfigGetterHelper = new DAIConfigGetterHelper();
		final DAIConfigView daiConfig = daiConfigGetterHelper.getDAIConfig(daiStatusCode);
		if(daiConfig != null) {
			daiStatusDesc = daiConfig.getDaiDescription();
		}
		return daiStatusDesc;
	}
}
