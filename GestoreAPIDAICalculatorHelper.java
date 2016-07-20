package it.sella.anagrafe.dai;

import it.sella.anagrafe.AnagrafeDAIException;
import it.sella.anagrafe.AnagrafeManagerFactory;
import it.sella.anagrafe.GestoreAnagrafeException;
import it.sella.anagrafe.GestoreAnagrafeFactory;
import it.sella.anagrafe.GestoreCodiciSoggettoException;
import it.sella.anagrafe.IDAIRegoleDetailsView;
import it.sella.anagrafe.LoggerTags;
import it.sella.anagrafe.OperazioneAnagrafeFactory;
import it.sella.anagrafe.SoggettoDAIDataView;
import it.sella.anagrafe.dbaccess.CSCifratiGetterHelper;
import it.sella.anagrafe.dbaccess.CodiceSoggettoDBAccessHelper;
import it.sella.anagrafe.factory.AnagrafeDAIFactory;
import it.sella.anagrafe.factory.FactoryException;
import it.sella.anagrafe.soaservices.util.SetXMLHandler;
import it.sella.anagrafe.util.AnagConfigurationHandler;
import it.sella.anagrafe.util.AnagrafeLoggerHelper;
import it.sella.anagrafe.util.CommonPropertiesHandler;
import it.sella.anagrafe.util.MapperHelperException;
import it.sella.anagrafe.util.logger.AnagrafeLoggerView;
import it.sella.anagrafe.util.logger.SecurityLoggerBuilder;
import it.sella.anagrafe.util.socket.SocketHelper;
import it.sella.anagrafe.view.AziendaView;
import it.sella.anagrafe.view.PersonaFisicaView;
import it.sella.anagrafe.view.PlurintestazioneView;
import it.sella.anagrafe.view.SoggettoView;
import it.sella.logserver.LoggerException;
import it.sella.util.Log4Debug;
import it.sella.util.Log4DebugFactory;

import java.rmi.RemoteException;
import java.util.Collection;
import java.util.Hashtable;
import java.util.Map;
import java.util.Properties;
import java.util.StringTokenizer;

/**
 * @author GBS03447
 *
 */
public class GestoreAPIDAICalculatorHelper {
	
	private static final Log4Debug log4Debug = Log4DebugFactory.getLog4Debug(GestoreAPIDAICalculatorHelper.class);
	private static final String DAIALERT = "DAIALERT";
	private static final String DAIOK = "DAIOK";
	
	/**
	 * @param soggettoId
	 * @throws GestoreAnagrafeException
	 * @throws RemoteException
	 */
	public Boolean calculateAndSetDAIForSoggetto(final Long soggettoId) throws GestoreAnagrafeException, RemoteException {
		Long opId = null;
		String errorMessage = null;
		Boolean calculatedDAI = null;
		final AnagrafeLoggerView loggerView = new AnagrafeLoggerView();
		loggerView.setSoggettoId(soggettoId);
		loggerView.setOperationCode("ANAG-SET-DAI-NEW");
		Boolean operationStatus = Boolean.TRUE;
		try {
			final Boolean newDAIConfigAllowed = AnagConfigurationHandler.isConfigurationAllowed("NewDaiAllowed");
			if(newDAIConfigAllowed){
				opId = new AnagrafeLoggerHelper().logAnagrafeOperation(null, false, "ANAG-SET-DAI-NEW", soggettoId, null);
				validateSoggettoId(soggettoId);
				final SoggettoView soggettoView = AnagrafeManagerFactory.getInstance().getAnagrafeManagerClientImpl().getSoggetto(soggettoId, new Properties());
				validateSoggettoView(soggettoView);

				final String tipoSoggetto = GestoreAnagrafeFactory.getInstance().getGestoreAnagrafe().getTipoSoggetto(soggettoId);
				final String parentTipoSoggetto = GestoreAnagrafeFactory.getInstance().getGestoreAnagrafe().getParentTipoSoggetto(soggettoId);
				
				if ("Semplice".equals(tipoSoggetto)) {
					calculatedDAI = calculateDAIForPFSoggetto(soggettoId, soggettoView, opId, loggerView);
				} else if ("Plurintestazione".equals(tipoSoggetto)) {
					calculatedDAI = calculateDAIForPLSoggetto(soggettoId, soggettoView, opId, loggerView);
				} else if ("AZIENDE".equals(parentTipoSoggetto)) {
					calculatedDAI = calculateDAIForAZSoggetto(soggettoId, soggettoView, opId, loggerView);
				} else {
					throw new AnagrafeDAIException("Tipo Soggetto Not Applicable For DAI Calculation.");
				}
			} else {
				operationStatus = Boolean.FALSE;
				errorMessage = "DAI Calculation not Allowed For this SoggettoId.";
			}
		} catch (final AnagrafeDAIException e) {
			log4Debug.debugStackTrace(e);
			operationStatus = Boolean.FALSE;
			errorMessage = e.getMessage();
			throw new GestoreAnagrafeException(e.getMessage());
		} catch (final LoggerException e) {
			operationStatus = Boolean.FALSE;
			log4Debug.debugStackTrace(e);
			errorMessage = e.getMessage();
			throw new GestoreAnagrafeException(e.getMessage());
		} finally {
			if(operationStatus){
				loggerView.withSuccess();
			}else {
				loggerView.withError(errorMessage);
			}
			new SecurityLoggerBuilder().buildLogger(loggerView);
			updateAnagrafeLog(opId, soggettoId, errorMessage);
		}
		log4Debug.debug("GestoreAPIDAICalculatorHelper =========  calculateDaiForSoggettoId  :::   calculatedDAI ======= ", calculatedDAI);
		return calculatedDAI;
	}
	
	/**
	 * @param soggettoId
	 * @throws AnagrafeDAIException
	 */
	private void validateSoggettoId(final Long soggettoId) throws AnagrafeDAIException {
		if (soggettoId == null) {
			throw new AnagrafeDAIException("Input soggetto Id Mandatory.");
		}
	}
	
	/**
	 * @param soggettoView
	 * @throws AnagrafeDAIException
	 */
	private void validateSoggettoView (final SoggettoView soggettoView) throws AnagrafeDAIException {
		if(soggettoView == null) {
			throw new AnagrafeDAIException("InValid SoggettoId.");
		}
	}
	
	/**
	 * Calculates DAI Regole Data and DAI Soggetto. If Old and new Dai Soggetto are different
	 * if new DAI Soggetto is ko then final dai is true..
	 * if new DAI soggetto is OK or alert .. then get the ARQuestionario DAI if its is OK or Alert .. then get Linked soggetto DAI .. if its OK or ALert then final dai is false or else true.
	 * if new DAI soggetto is OK and get the principle soggettos (az & PL) .. calculate dai for principle soggettos
	 * @param soggettoId
	 * @param soggettoView
	 * @throws AnagrafeDAIException 
	 * @throws RemoteException 
	 */
	public Boolean calculateDAIForPFSoggetto(final Long soggettoId, final SoggettoView soggettoView, final Long opId, final AnagrafeLoggerView loggerView) throws AnagrafeDAIException, RemoteException {
		Boolean daiCalculated =  Boolean.TRUE;
		final AnagrafeDAIFactory anagrafeDAIFactory = new AnagrafeDAIFactory();
		final DaiRegoleSoggettohelper daiRegoleSoggettohelper = new DaiRegoleSoggettohelper();
		final PersonaFisicaView personaFisicaView = (PersonaFisicaView) soggettoView;
		final Collection<IDAIRegoleDetailsView> daiRegoleOldData = personaFisicaView.getDaiRegoleView();
		final SoggettoDAIDataView daiSoggettoOldView = personaFisicaView.getDaiSoggettoView(); // TO Log
		final Boolean OldAttributiDAI = personaFisicaView.getAttributiEsterniPFView() != null ? personaFisicaView.getAttributiEsterniPFView().getNewDai(): null;
		final Boolean arDAIConfigAllowed = AnagConfigurationHandler.isConfigurationAllowed("ARDaiAllowed");
		String daiFromARQuestinario = null;
		String collegateDaiStatus = null;
		String daiSoggettoStatusNew = null;
		String daiSoggettoStatusOld = null;
		try {
			final Collection<IDAIRegoleDetailsView> daiRegoleData = daiRegoleSoggettohelper.processDaiRegoleData(personaFisicaView, "Semplice");
			if(daiRegoleData != null) {
				anagrafeDAIFactory.setDAIRegole(daiRegoleData, daiRegoleOldData, soggettoId, opId);
				final SoggettoDAIDataView daiSoggetto = daiRegoleSoggettohelper.calculateDaiFromRegoleData(daiRegoleData);
				
				if(daiSoggetto != null) {
					OperazioneAnagrafeFactory.getInstance().getOperazioneAnagrafeManager().setDAISoggetto(daiSoggetto, soggettoId, opId);
					daiSoggettoStatusNew = getDAIStatusCode(daiSoggetto);
					daiSoggettoStatusOld = getDAIStatusCode(daiSoggettoOldView); // TO Log
					daiFromARQuestinario = daiRegoleSoggettohelper.getARQuestionarioDAIAVForSoggetto(soggettoId, arDAIConfigAllowed);
					collegateDaiStatus = daiRegoleSoggettohelper.getCollegateSubjectsDAIStatus(personaFisicaView.getCollegateViews());
					
					if ((DAIOK.equals(daiSoggettoStatusNew) || DAIALERT.equals(daiSoggettoStatusNew)) && (daiFromARQuestinario == null || DAIOK.equals(daiFromARQuestinario) || DAIALERT.equals(daiFromARQuestinario))
							&& (DAIOK.equals(collegateDaiStatus) || DAIALERT.equals(collegateDaiStatus))) {
						daiCalculated = Boolean.FALSE;
					}
					log4Debug.debug("calculateDAIForPFSoggetto ===========  PF Final DAI  =========   ", daiCalculated);
					final Boolean daiSwitchAllowed = AnagConfigurationHandler.isConfigurationAllowed("DAISwitch");
					anagrafeDAIFactory.setAttributiDAIForSoggetto(soggettoId, daiCalculated.booleanValue(), daiSwitchAllowed , opId);
					
					if(DAIOK.equals(daiSoggettoStatusNew) || DAIALERT.equals(daiSoggettoStatusNew)) {
						//daiRegoleSoggettohelper.updateDAIForPrincipleSoggettoAZ(personaFisicaView.getId(), opId, daiSwitchAllowed); // As For DAI Calculation, Azienda Subject we are not Considering Linked DAI This Call Commented.
						final Collection<Long> principlePLSogg = daiRegoleSoggettohelper.updateDAIForPrincipleSoggettoPL(personaFisicaView.getId(), opId, arDAIConfigAllowed, daiSwitchAllowed);
						if(principlePLSogg != null && !principlePLSogg.isEmpty()) {
							for (final Long soggettoIdPL : principlePLSogg) {
								updateDAIWithHost(soggettoIdPL, daiCalculated, true);// DAI Host call update for PL Soggetto's (priciple sogg to PF)
							}
						}
		            }
					updateDAIWithHost(soggettoId, daiCalculated, true); // For PF Update DAi with HOST
				}
			}
		} catch (final FactoryException e) {
			log4Debug.debugStackTrace(e);
			throw new AnagrafeDAIException(e.getMessage());
		} finally {
			final Map<Object, Object> detailMap = new Hashtable<Object, Object>();
			setInMapAfterNullCheck("DAIANAGRAFE_OLD", daiSoggettoStatusOld, detailMap);
			setInMapAfterNullCheck("DAIANAGRAFE_NEW", daiSoggettoStatusNew, detailMap);
			setInMapAfterNullCheck("DAI_ARQ", daiFromARQuestinario, detailMap);
			setInMapAfterNullCheck("DAI_LINKED", collegateDaiStatus, detailMap);
			setInMapAfterNullCheck("FINAL_DAI_OLD", OldAttributiDAI, detailMap);
			setInMapAfterNullCheck("FINAL_DAI_NEW", daiCalculated, detailMap);
			setInMapAfterNullCheck("AR_DAI_ALLOWED", arDAIConfigAllowed, detailMap);
			constructXMLForModifica(loggerView, detailMap);
		}
		return daiCalculated;
	}

	/**
	 * For Azienda Subject Linked PF DAI not Considering in DAI Calulation for censimento and Varia. Linked DAI calculation Commented below..
	 * @param soggettoId
	 * @param soggettoView
	 * @throws AnagrafeDAIException 
	 * @throws RemoteException 
	 */
	public Boolean calculateDAIForAZSoggetto(final Long soggettoId, final SoggettoView soggettoView, final Long opId, final AnagrafeLoggerView loggerView) throws AnagrafeDAIException, RemoteException {
		Boolean daiCalculated =  Boolean.TRUE;
		final AnagrafeDAIFactory anagrafeDAIFactory = new AnagrafeDAIFactory();
		final DaiRegoleSoggettohelper daiRegoleSoggettohelper = new DaiRegoleSoggettohelper();
		final AziendaView aziendaView = (AziendaView) soggettoView;
		final Collection<IDAIRegoleDetailsView> daiRegoleOldData = aziendaView.getDaiRegoleView();
		final SoggettoDAIDataView daiSoggettoOldView = aziendaView.getDaiSoggettoView();  // TO Log
		final Boolean OldAttributiDAI = aziendaView.getAttributiEsterniAZView() != null ? aziendaView.getAttributiEsterniAZView().getNewDai() : null;
		final Boolean arDAIConfigAllowed = AnagConfigurationHandler.isConfigurationAllowed("ARDaiAllowed");
		String daiFromARQuestinario = null;
		//String collegateDAIStatus = null;
		String daiSoggettoStatusNew = null;
		String daiSoggettoStatusOld = null;
		try {
			final Collection<IDAIRegoleDetailsView> daiRegoleData = daiRegoleSoggettohelper.processDaiRegoleData(aziendaView, "AZIENDE");
			if(daiRegoleData != null) {
				anagrafeDAIFactory.setDAIRegole(daiRegoleData, daiRegoleOldData, soggettoId, opId);
				final SoggettoDAIDataView daiSoggetto = daiRegoleSoggettohelper.calculateDaiFromRegoleData(daiRegoleData);
				
				if (daiSoggetto != null) {
					OperazioneAnagrafeFactory.getInstance().getOperazioneAnagrafeManager().setDAISoggetto(daiSoggetto, soggettoId, opId);
					daiSoggettoStatusNew = getDAIStatusCode(daiSoggetto);
					daiSoggettoStatusOld = getDAIStatusCode(daiSoggettoOldView);  // TO Log
					daiFromARQuestinario = daiRegoleSoggettohelper.getARQuestionarioDAIAVForSoggetto(soggettoId, arDAIConfigAllowed);
					//collegateDAIStatus = daiRegoleSoggettohelper.getCollegateSubjectsDAIStatus(aziendaView.getCollegateViews());
					
					if((DAIOK.equals(daiSoggettoStatusNew) || DAIALERT.equals(daiSoggettoStatusNew)) && (daiFromARQuestinario == null ||DAIOK.equals(daiFromARQuestinario) || DAIALERT.equals(daiFromARQuestinario)) 
							/*&& (DAIOK.equals(collegateDAIStatus) || DAIALERT.equals(collegateDAIStatus))*/) {
						daiCalculated = Boolean.FALSE;
					}
					log4Debug.debug("calculateDAIForAZSoggetto ===========  AZ Final DAI  =========   ", daiCalculated);
					anagrafeDAIFactory.setAttributiDAIForSoggetto(soggettoId, daiCalculated.booleanValue(), AnagConfigurationHandler.isConfigurationAllowed("DAISwitch") , opId);
					
					//Host Call update For DAI
					updateDAIWithHost(soggettoId, daiCalculated, true);
				}
			}
		} catch (final FactoryException e) {
			log4Debug.debugStackTrace(e);
			throw new AnagrafeDAIException(e.getMessage());
		} finally {
			final Map<Object, Object> detailMap = new Hashtable<Object, Object>();
			setInMapAfterNullCheck("DAIANAGRAFE_OLD", daiSoggettoStatusOld, detailMap);
			setInMapAfterNullCheck("DAIANAGRAFE_NEW", daiSoggettoStatusNew, detailMap);
			setInMapAfterNullCheck("DAI_ARQ", daiFromARQuestinario, detailMap);
			//setInMapAfterNullCheck("DAI_LINKED", collegateDAIStatus, detailMap);
			setInMapAfterNullCheck("FINAL_DAI_OLD", OldAttributiDAI, detailMap);
			setInMapAfterNullCheck("FINAL_DAI_NEW", daiCalculated, detailMap);
			setInMapAfterNullCheck("AR_DAI_ALLOWED", arDAIConfigAllowed, detailMap);
			constructXMLForModifica(loggerView, detailMap);
		}
		return daiCalculated;
	}

	/**
	 * @param soggettoId
	 * @param soggettoView
	 * @throws AnagrafeDAIException 
	 * @throws RemoteException 
	 */
	public Boolean calculateDAIForPLSoggetto(final Long soggettoId, final SoggettoView soggettoView, final Long opId, final AnagrafeLoggerView loggerView) throws AnagrafeDAIException, RemoteException {
		Boolean daiCalculated =  Boolean.TRUE;
		final PlurintestazioneView plurintestazioneView = (PlurintestazioneView) soggettoView;
		final Boolean OldAttributiDAI = plurintestazioneView.getAttributiEsterniPLView() != null ? plurintestazioneView.getAttributiEsterniPLView().getNewDai() : null;
		final Collection soggettoIds = plurintestazioneView.getSoggettoIds();
		final Boolean arDAIConfigAllowed = AnagConfigurationHandler.isConfigurationAllowed("ARDaiAllowed");
		String plIntestarioDAIStatus = null;
		try {
			if (soggettoIds != null && !soggettoIds.isEmpty()) {
				plIntestarioDAIStatus = new DaiRegoleSoggettohelper().getPLIntestarioDAIStatus(soggettoIds, arDAIConfigAllowed);
				
				if(DAIOK.equals(plIntestarioDAIStatus) || DAIALERT.equals(plIntestarioDAIStatus)) {
					daiCalculated = Boolean.FALSE;
				}
				new AnagrafeDAIFactory().setAttributiDAIForSoggetto(soggettoId, daiCalculated.booleanValue(), AnagConfigurationHandler.isConfigurationAllowed("DAISwitch") , opId);
				
				//Host Call update For DAI
				updateDAIWithHost(soggettoId, daiCalculated, true);
			}
		} catch (final FactoryException e) {
			log4Debug.debugStackTrace(e);
			throw new AnagrafeDAIException(e.getMessage());
		} finally {
			final Map<Object, Object> detailMap = new Hashtable<Object, Object>();
			setInMapAfterNullCheck("DAI_LINKED", plIntestarioDAIStatus, detailMap);
			setInMapAfterNullCheck("FINAL_DAI_OLD", OldAttributiDAI, detailMap);
			setInMapAfterNullCheck("FINAL_DAI_NEW", daiCalculated, detailMap);
			setInMapAfterNullCheck("AR_DAI_ALLOWED", arDAIConfigAllowed, detailMap);
			constructXMLForModifica(loggerView, detailMap);
		}
		return daiCalculated;
	}
	
	/**
	 * @param daiSoggettoView
	 * @return
	 */
	private String getDAIStatusCode (final SoggettoDAIDataView daiSoggettoView) {
		String weightage = null;
		if(daiSoggettoView != null && daiSoggettoView.getDaiWeightId() != null) {
			weightage = daiSoggettoView.getDaiWeightId().getDaiConfigCode();
		}
		return weightage;
	}
	
	/**
	 * @param opId
	 * @param soggettoId
	 * @param errorMessage
	 */
	private void updateAnagrafeLog(final Long opId, final Long soggettoId, final String errorMessage) {
		try {
    		if( opId != null && errorMessage != null ) {
    			new AnagrafeLoggerHelper().updateAnagrafeLog(opId, soggettoId, errorMessage);
    		}
		} catch (final Exception e) {
            log4Debug.warnStackTrace(e);
		}
	}
	
	/**
	 * @param loggerView
	 * @param detailsMap
	 */
	private void constructXMLForModifica(final AnagrafeLoggerView loggerView, final Map<Object, Object> detailsMap) {
		final String oldDataXML = SetXMLHandler.getTagWithNullCheck(LoggerTags.OLD_VALUES.getValue(), constructXMLForOLDDAISoggetto(detailsMap));
		final String newDataXML = SetXMLHandler.getTagWithNullCheck(LoggerTags.NEW_VALUES.getValue(), constructXMLForNEWDAISoggetto(detailsMap));
		loggerView.setInputXML(SetXMLHandler.getTagWithNullCheck(LoggerTags.MODIFICA.getValue(), oldDataXML.concat(newDataXML)));
	}
	
	/**
	 * @param detailsMap
	 * @return
	 */
	private String constructXMLForNEWDAISoggetto(final Map<Object, Object> detailsMap) {
		final StringBuffer logBuffer = new StringBuffer();
		logBuffer.append(SetXMLHandler.getTagWithValueNullCheck("DAI_SOGGETTO", detailsMap.get("DAIANAGRAFE_NEW")));
		logBuffer.append(SetXMLHandler.getTagWithValueNullCheck("AR_DAI_ALLOWED", detailsMap.get("AR_DAI_ALLOWED")));
		logBuffer.append(SetXMLHandler.getTagWithValueNullCheck("ARQ_DAI", detailsMap.get("DAI_ARQ")));
		logBuffer.append(SetXMLHandler.getTagWithValueNullCheck("LINKED_SOGG_DAI", detailsMap.get("DAI_LINKED")));
		logBuffer.append(SetXMLHandler.getTagWithValueNullCheck("ATTRIBUTI_DAI", detailsMap.get("FINAL_DAI_NEW")));
		return logBuffer.toString();
	}
	
	/**
	 * @param detailsMap
	 * @return
	 */
	private String constructXMLForOLDDAISoggetto(final Map<Object, Object> detailsMap) {
		final StringBuffer logBuffer = new StringBuffer();
		logBuffer.append(SetXMLHandler.getTagWithValueNullCheck("DAI_SOGGETTO", detailsMap.get("DAIANAGRAFE_OLD")));
		logBuffer.append(SetXMLHandler.getTagWithValueNullCheck("ATTRIBUTI_DAI", detailsMap.get("FINAL_DAI_OLD")));
		return logBuffer.toString();
	}
	
	/**
	 * @param key
	 * @param value
	 * @param map
	 */
	private void setInMapAfterNullCheck( final Object key, final Object value, final Map<Object, Object> map) {
		if(key != null && value != null && map != null) {
			map.put(key, value);
		}
	}
	
	/**
	 * @param soggettoId
	 * @param daiValue
	 * @param codiceHost
	 * @param isHostCodeFromSecurity
	 * @throws RemoteException
	 * @throws AnagrafeDAIException
	 */
	public void updateDAIWithHost (final Long soggettoId, final Boolean daiValue, final boolean isHostCodeFromSecurity) throws RemoteException, AnagrafeDAIException {
		log4Debug.debug(" ===============   DAI API HOST CALL  =============updateDAIWithHost============ ",soggettoId, " ==========daiValue========= ",daiValue);
		String codiceHostValue = null;
		try {
			if(CommonPropertiesHandler.isHostAllowedForLoginBank()) {
				final SocketHelper socketHelper = new SocketHelper();
				final String codiceHost = getCodiceHostForSoggettoId(soggettoId);
				log4Debug.debug("updateDAIWithHost ======================= codiceHost  ==================  ",codiceHost);
				if (codiceHost != null && !"".equals(codiceHost)) {
					final StringTokenizer codiceHostTokens = new StringTokenizer(codiceHost, ";");
		            while (codiceHostTokens.hasMoreTokens()) { 
		            	codiceHostValue = codiceHostTokens.nextToken();
		            	socketHelper.updateDaiSH(soggettoId, getA78Message(daiValue), codiceHostValue, null, isHostCodeFromSecurity);
		            }
				}
	            
	            final String codiceHostCifrati = new CSCifratiGetterHelper().getCodiceHostCifrati(soggettoId);
	            log4Debug.debug("updateDAIWithHost ======================= codiceHostCifrati  ==================  ",codiceHostCifrati);
	            if(codiceHostCifrati != null) {
	            	final StringTokenizer codiceHostTokens = new StringTokenizer(codiceHostCifrati,";");
					while(codiceHostTokens.hasMoreTokens()) {
						codiceHostValue = codiceHostTokens.nextToken();
						if(codiceHostValue.length() == 9) {
							codiceHostValue = codiceHostValue.substring(1,9);
						}
						socketHelper.updateDaiSH(soggettoId, getA78Message(daiValue), codiceHostValue, null, isHostCodeFromSecurity);
					}
				}
			}
		} catch (final MapperHelperException e) {
			log4Debug.severeStackTrace(e);
			throw new AnagrafeDAIException(e.getMessage(),e);
		} catch (final GestoreCodiciSoggettoException e) {
			log4Debug.severeStackTrace(e);
			throw new AnagrafeDAIException(e.getMessage(),e);
		}
	}
	
	private String getA78Message(final Boolean daiValue) {
    	final StringBuffer output = new StringBuffer("A78");
    	output.append(daiValue == null || daiValue.booleanValue() == false ? 0 : 1 );
    	output.append(",");
		return output.toString();
	}
	
	/**
	 * @param soggettoId
	 * @return
	 * @throws GestoreCodiciSoggettoException
	 * @throws RemoteException
	 */
	private String getCodiceHostForSoggettoId(final Long soggettoId) throws GestoreCodiciSoggettoException, RemoteException {
		final String codiceHost = new CodiceSoggettoDBAccessHelper().getValoreCodiciSoggetto(soggettoId, "codiceHost");
		log4Debug.debug("getCodiceHostForSoggettoId ======================= codiceHost  ==================  ",codiceHost);
		final StringBuffer codiceHostValues = new StringBuffer();
		if (codiceHost != null){
            final String [] codiceHostArray = codiceHost.split(";");
			String splitCodiceHost = null;
			for(int i=0; i < codiceHostArray.length ; i++) {
				splitCodiceHost = codiceHostArray[i];
				if(splitCodiceHost.startsWith("0")) {
					if(codiceHostValues.length() > 0) {
						codiceHostValues.append(";");
						codiceHostValues.append(splitCodiceHost.subSequence(1, 9));
					} else {
						codiceHostValues.append(splitCodiceHost.subSequence(1, 9));
					}
				}
			}
		}
		return codiceHostValues.toString();
	}
}
