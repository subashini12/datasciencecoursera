package it.sella.anagrafe.implementation;

import it.sella.address.AddressException;
import it.sella.address.AddressManagerFactory;
import it.sella.address.egon.view.EgonView;
import it.sella.anagrafe.GestoreCittaException;
import it.sella.anagrafe.GestoreCodiciSoggettoException;
import it.sella.anagrafe.GestoreCollegamentoException;
import it.sella.anagrafe.GestoreDatiAnagrafeException;
import it.sella.anagrafe.GestoreDatiFiscaliException;
import it.sella.anagrafe.InformazioneManagerException;
import it.sella.anagrafe.ResourceLookupException;
import it.sella.anagrafe.az.FatcaAZView;
import it.sella.anagrafe.common.AlboProfessione;
import it.sella.anagrafe.common.CAP;
import it.sella.anagrafe.common.Citta;
import it.sella.anagrafe.common.Nazione;
import it.sella.anagrafe.common.Provincia;
import it.sella.anagrafe.common.Ramo;
import it.sella.anagrafe.common.RecapitiCanaleComptView;
import it.sella.anagrafe.common.Settore;
import it.sella.anagrafe.common.SettoreDiAttivita;
import it.sella.anagrafe.common.TAE;
import it.sella.anagrafe.dbaccess.CompDocumentDBAccessHelper;
import it.sella.anagrafe.implementation.operazioneanagrafe.OperazioneAnagrafeSession;
import it.sella.anagrafe.implementation.operazioneanagrafe.OperazioneAnagrafeSessionHome;
import it.sella.anagrafe.originecliente.OrigineClienteMasterView;
import it.sella.anagrafe.util.ResourceLookupHelper;
import it.sella.anagrafe.util.SecurityHandler;
import it.sella.anagrafe.view.CompDocumentView;
import it.sella.anagrafe.view.InvalidDocumentoView;
import it.sella.classificazione.ClassificazioneView;
import it.sella.intestatazione.IntestatazioneException;
import it.sella.intestatazione.IntestatazioneManagerFactory;
import it.sella.util.Log4Debug;
import it.sella.util.Log4DebugFactory;

import java.io.Serializable;
import java.rmi.RemoteException;
import java.util.Collection;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;

import javax.ejb.Handle;

/**
 This informazioneManager which does the look up to the GeograficaValidatorImpl
 and it has the methods which are static and all these methods are wrapper to the
 GeograficaValidatorImpl
 */

public class InformazioneManager implements Serializable {

    /**
	 *
	 */
	private static final long serialVersionUID = 1L;
	private transient GeograficaValidatorImpl geograficaValidatorImpl = null;
    private transient AnagrafeManager anagrafeManager = null;
    private transient GestoreAnagrafeImpl gestoreAnagrafeImpl = null;
    private transient OperazioneAnagrafeSession operazioneAnagrafeManager = null;

    private Handle geograficaValidatorHandle = null;
    private Handle anagrafeManagerHandle = null;
    private Handle gestoreAnagrafeHandle = null;
    private Handle operazioneAnagrafeHandle = null;

    public static AnagrafeInformazioneCache anagrafeInformazioneCache = new AnagrafeInformazioneCache();
    private Long bancaId = null;

    private static final Log4Debug log4Debug = Log4DebugFactory.getLog4Debug(InformazioneManager.class);

    public void init() throws InformazioneManagerException {
        try {
            if(geograficaValidatorImpl == null && geograficaValidatorHandle == null) {
                geograficaValidatorImpl = getGeograficaValidatorImplHome().create();
                geograficaValidatorHandle = geograficaValidatorImpl.getHandle();
            } else if(geograficaValidatorImpl == null && geograficaValidatorHandle != null) {
                geograficaValidatorImpl = (GeograficaValidatorImpl) geograficaValidatorHandle.getEJBObject();
            }

            if(operazioneAnagrafeManager == null && operazioneAnagrafeHandle == null) {
                operazioneAnagrafeManager = getOperazioneAnagrafeSessionHome().create();
                operazioneAnagrafeHandle = operazioneAnagrafeManager.getHandle();
            } else if(operazioneAnagrafeManager == null && operazioneAnagrafeHandle != null) {
                operazioneAnagrafeManager = (OperazioneAnagrafeSession) operazioneAnagrafeHandle.getEJBObject();
            }

            if(gestoreAnagrafeImpl == null && gestoreAnagrafeHandle == null) {
                gestoreAnagrafeImpl = getGestoreAnagrafeImplHome().create();
                gestoreAnagrafeHandle = gestoreAnagrafeImpl.getHandle();
            } else if(gestoreAnagrafeImpl == null && gestoreAnagrafeHandle != null) {
                gestoreAnagrafeImpl = (GestoreAnagrafeImpl) gestoreAnagrafeHandle.getEJBObject();
            }

            if(anagrafeManager == null && anagrafeManagerHandle == null) {
                anagrafeManager = getAnagrafeManagerHome().create();
                anagrafeManagerHandle = anagrafeManager.getHandle();
            } else if(anagrafeManager == null && anagrafeManagerHandle != null) {
                anagrafeManager = (AnagrafeManager) anagrafeManagerHandle.getEJBObject();
            }
        } catch(final Exception e) {
            log4Debug.severeStackTrace(e);
            throw new InformazioneManagerException(e.getMessage());
        }
    }

    public void initBancaId() throws InformazioneManagerException {
        try {
            bancaId = SecurityHandler.getLoginBancaId();
        } catch(final Exception e) {
            log4Debug.severeStackTrace(e);
            throw new InformazioneManagerException(e.getMessage());
        }
    }

    private OperazioneAnagrafeSession getOperazioneAnagrafeManager() throws RemoteException {
        return operazioneAnagrafeManager == null && operazioneAnagrafeHandle != null ?
        		operazioneAnagrafeManager = (OperazioneAnagrafeSession) operazioneAnagrafeHandle.getEJBObject() : operazioneAnagrafeManager;
    }


    /** This method doesn't take any arguments
     @return Collection of nazione Views
     */

    public Collection listNazione() throws RemoteException {
        return getGeograficaValidatorImpl().listNazione();
    }

    /**
       @param nazioneNome String
       @return Collection of nazione Views
     */

    public Collection listNazione(final String nazioneNome) throws RemoteException {
        return getGeograficaValidatorImpl().listNazione(nazioneNome);
    }

    /** This method doesn't take any arguments and it gives all the
     naziones but where nazione = 1
     @ return Collection of nazione Views
    */

    public Collection listAnagraficNazione() throws RemoteException {
        return getGeograficaValidatorImpl().listAnagraficNazione();
    }

    /** This method returns a nazione
     @ param Long nazioneid
     @ return Nazione
     */

    public Nazione getNazione(final Long nazioneId) throws RemoteException {
        if(anagrafeInformazioneCache.isNazioneExists(nazioneId)) {
            return anagrafeInformazioneCache.getNazione(nazioneId);
        } else {
            final Nazione nazione = getGeograficaValidatorImpl().getNazione(nazioneId);
            anagrafeInformazioneCache.putNazione(nazioneId, nazione);
            return nazione;
        }
    }

    /** This method returns a nazione
     @ param String nazionename
     @ return Nazione
     */

    public Nazione getNazione(final String nazione) throws RemoteException {
        return getGeograficaValidatorImpl().getNazione(nazione);
    }

    /** This method returns a nazione
     @ param String nazionename
     @ return Nazione
     */

    public Nazione getNazioneForIndirizzo(final String nazioneNome) throws RemoteException {
        return getGeograficaValidatorImpl().getNazioneForIndirizzo(nazioneNome);
    }

    /** This method checks whether the cap is valid or not
     @ param String cap
     @ return boolean
     */

    public boolean isValidCAP(final String cap) throws RemoteException {
        return getGeograficaValidatorImpl().isValidCAP(cap);
    }

    /** This method checks whether the cap is valid or not
     @ param String cap
     @ param String provincia
     @ return boolean
     */

    public boolean isValidCAP(final String cap, final String provincia) throws RemoteException {
        return getGeograficaValidatorImpl().isValidCAP(cap, provincia);
    }

    /** This method checks whether the province is valid or not
     @ param String provincia
     @ return boolean
     */

    public boolean isValidProvince(final String province) throws RemoteException {
        return getGeograficaValidatorImpl().isValidProvince(province);
    }

    /** This method checks whether the province is valid or not
     @ param String provincia
     @ param String citta
     @ return boolean
     */

    public boolean isValidProvince(final String province, final String citta) throws RemoteException {
        return getGeograficaValidatorImpl().isValidProvince(province, citta);
    }

    /** This method checks whether the citta is valid or not
     @ param String citta
     @ return boolean
     */

    public boolean isValidCitta(final String cittaName) throws RemoteException {
        //return getGeograficaValidatorImpl().isValidCitta(cittaName);
        try {
            return getGestoreAnagrafeImpl().isValidAnagraficCitta(cittaName);
        } catch(final GestoreCittaException gce) {
            throw new RemoteException(gce.getMessage());
        }
    }

    /** This method retrieves the citta
     @ param String citta
     @ param String provincia
     @ return Citta object
     */

    public Citta getCitta(final String cittaName, final String province) throws RemoteException {
        return getGeograficaValidatorImpl().getCitta(cittaName, province);
    }

    /** This method retrieves the citta
     @ param Long cittaId
     @ return Citta object
     */

    public Citta getCitta(final Long cittaId) throws RemoteException {
        //return getGeograficaValidatorImpl().getCitta(cittaId);
        if(anagrafeInformazioneCache.isCittaExists(cittaId)) {
            return anagrafeInformazioneCache.getCitta(cittaId);
        } else {
            final Citta citta = getGeograficaValidatorImpl().getCitta(cittaId);
            anagrafeInformazioneCache.putCitta(cittaId, citta);
            return citta;
        }
    }

    /** This method retrieves the cittas
     @ param String cittaname
     @ return Collection of Citta objects
     */

    public Collection getCittaCollection(final String cittaName) throws RemoteException {
        return getGeograficaValidatorImpl().getCittaCollection(cittaName);
    }

    /** This method retrieves the citta and checks for storico
     @ param String cittaname
     @ return citta object
     */

    public Citta getCitta(final String cittaName) throws RemoteException {
        return getGeograficaValidatorImpl().getCitta(cittaName);
    }

    /** This method retrieves the citta
     @ param String cittaname
     @ return citta object
     */

    public Citta getAnagraficCitta(final String cittaName) throws RemoteException {
        return getGeograficaValidatorImpl().getAnagraficCitta(cittaName);
    }

    /**
     * This returns the lingua
     * @ return Collection
     */

    public Collection listLingua() throws RemoteException {
        return getGeograficaValidatorImpl().listLingua();
    }

    /**
     * The method which retrieves the data of titolo1 using classificazione
     * @return Collection
     */

    public Collection listTitolo1() throws RemoteException {
        return getGeograficaValidatorImpl().listTitolo1();
    }

    /**
     * The method which retrieves the data of titolo2 using classificazione
     * @return Collection
     */

    public Collection listTitolo2() throws RemoteException {
        return getGeograficaValidatorImpl().listTitolo2();
    }

    /**
     * The method which retrieves the data of sesso using classificazione
     * @return Collection
     */

    public Collection listSesso() throws RemoteException {
        return getGeograficaValidatorImpl().listSesso();
    }

    /**
     * The method which retrieves the data of professione using classificazione
     * @return Collection
     */

    public Collection listProfessione() throws RemoteException {
        return getGeograficaValidatorImpl().listProfessione();
    }

    /**
     * The method which retrieves the data of statocivile using classificazione
     * @return Collection
     */

    public Collection listStatoCivile() throws RemoteException {
        return getGeograficaValidatorImpl().listStatoCivile();
    }

    /**
     * The method which retrieves the data of patrimoniale using classificazione
     * @return Collection
     */

    public Collection listRegimePatrimoniale() throws RemoteException {
        return getGeograficaValidatorImpl().listRegimePatrimoniale();
    }

    /**
     * The method which retrieves the data of TitoloDiStudio using classificazione
     * @return Collection
     */

    public Collection listTitoloDiStudio() throws RemoteException {
        return getGeograficaValidatorImpl().listTitoloDiStudio();
    }

    /**
     * The method which retrieves the data of TitoloDiStudio using classificazione
     * @return Collection
     * @ exception RemoteException, InformazioneManagerException
     */

    public Collection listRamo() throws InformazioneManagerException, RemoteException {
        return getGeograficaValidatorImpl().listRamo();
    }

    /**
     * The method which retrieves the Ramo using codicegruppo
     * @param codiceGruppo
     * @return Ramo
     * @ exception RemoteException, InformazioneManagerException
     */

    public Ramo getRamo(final String codiceGruppo) throws InformazioneManagerException, RemoteException {
        return getGeograficaValidatorImpl().getRamo(codiceGruppo);
    }

    /** This method retrieves the citta
    @ param Long cittaId
    @ return Citta object
    */

   public Ramo getRamo(final Long ramoId) throws RemoteException {
       //return getGeograficaValidatorImpl().getCitta(cittaId);
       if(anagrafeInformazioneCache.isRamoExists(ramoId)) {
           return anagrafeInformazioneCache.getRamo(ramoId);
       } else {
           final Ramo ramo = getGeograficaValidatorImpl().getRamo(ramoId);
           anagrafeInformazioneCache.putRamo(ramoId, ramo);
           return ramo;
       }
   }


    /**
     * The method which retrieves the Settore using codiceSottoGruppo
     * @param codiceSottoGruppo
     * @return Settore
     * @ exception RemoteException, InformazioneManagerException
     */

    public Settore getSettore(final String codiceSottoGruppo) throws InformazioneManagerException, RemoteException {
        return getGeograficaValidatorImpl().getSettore(codiceSottoGruppo);
    }

    /**
     * The method which retrieves the data of TitoloDiStudio using classificazione
     * @return Collection
     * @ exception RemoteException, InformazioneManagerException
     */

    public Collection listSettore(final Long tipoSoggettoId,final Long tipoSocietaId) throws InformazioneManagerException, RemoteException {
        return getGeograficaValidatorImpl().listSettore(tipoSoggettoId,tipoSocietaId);
    }

    public Collection listSettore(final Long tipoSoggettoId) throws InformazioneManagerException, RemoteException {
        return getGeograficaValidatorImpl().listSettore(tipoSoggettoId);
    }


    public Collection getAllSettore() throws InformazioneManagerException, RemoteException {
        return getGeograficaValidatorImpl().getAllSettore();
    }

    /**
     * The method which retrieves the data of TitoloDiStudio using classificazione
     * @return Collection
     * @ exception RemoteException, InformazioneManagerException
     */

    public Collection listAttivita() throws InformazioneManagerException, RemoteException {
        return getGeograficaValidatorImpl().listAttivita();
    }

    /** This method returns the attivita details
     * @ return Collection collection of attivita objects
     * @ exception InformazioneManagerException, RemoteException
     */
    public Collection getCompatibleAttivita(final String ramo) throws InformazioneManagerException,RemoteException {
        return getGeograficaValidatorImpl().getCompatibleAttivita(ramo);
    }

    /** This method retrieves the descrizione of attivita
     * @ return String
     * @ exception InformazioneManagerException, RemoteException
     */
    public String getAttivitaDescrizione(final String codiceISTAT) throws InformazioneManagerException,RemoteException {
        return getGeograficaValidatorImpl().getAttivitaDescrizione(codiceISTAT);
    }


    /** The method which retrieves the data of TitoloDiStudio using classificazione
     * @return Collection
     * @ exception RemoteException, InformazioneManagerException
     */

    public Collection listTipoSocieta() throws InformazioneManagerException, RemoteException {
        return getGeograficaValidatorImpl().listTipoSocieta();
    }

    /** This method returns a provincia object
     * @ param Long provinceId
     * @ return Provincia object
     */

    public Provincia getProvincia(final Long provinceId) throws RemoteException {
        //return  getGeograficaValidatorImpl().getProvincia(provinceId);
        if(anagrafeInformazioneCache.isProvinciaExists(provinceId)) {
            return anagrafeInformazioneCache.getProvincia(provinceId);
        } else {
            final Provincia provincia = getGeograficaValidatorImpl().getProvincia(provinceId);
            anagrafeInformazioneCache.putProvincia(provinceId, provincia);
            return provincia;
        }
    }

    /** This method returns a provincia object
     * @ param String provinceSigla
     * @ return Provincia object
     */

    public Provincia getProvincia(final String provinceSigla) throws RemoteException {
        return getGeograficaValidatorImpl().getProvincia(provinceSigla);
    }

    /** This method returns collection of provincia object
     * @ param String provinceSigla
     * @ return Collection
     */

    public Collection getAllProvincia(final String provinceSigla) throws RemoteException {
        return getGeograficaValidatorImpl().getAllProvincia(provinceSigla);
    }

    /** This method returns collection of provincia object
     * @ param String provinceNome
     * @ return Collection
     */

    public Collection getAllProvinciaByName(final String provinciaNome) throws RemoteException {
        return getGeograficaValidatorImpl().getAllProvinciaByName(provinciaNome);
    }

    public CAP getCap(final Long capId) throws RemoteException {
        return getGeograficaValidatorImpl().getCap(capId);
    }

    public CAP getCap(final String capId) throws RemoteException {
        return getGeograficaValidatorImpl().getCap(capId);
    }

    public Collection getAllCaps(final String capValue) throws RemoteException {
        return getGeograficaValidatorImpl().getAllCaps(capValue);
    }

    public CAP getCap(final String caCap, final Citta citta) throws RemoteException {
        return getGeograficaValidatorImpl().getCap(caCap, citta);
    }

    public Collection getCompatibleTipoRecapiti(final String tipoSoggettoSecondLevelName) throws RemoteException {
        return getOperazioneAnagrafeManager().getCompatibleTipoRecapiti(tipoSoggettoSecondLevelName);
    }

    public Collection getCompatibleTipoEventi(final String tipoSoggettoSecondLevelName) throws RemoteException {
        return getOperazioneAnagrafeManager().getCompatibleTipoEventi(tipoSoggettoSecondLevelName);
    }

    public Collection getCompatibleTipoDocumeni(final String tipoSoggettoSecondLevelName) throws RemoteException {
        return getOperazioneAnagrafeManager().getCompatibleTipoDocumeni(tipoSoggettoSecondLevelName);
    }

    public List<CompDocumentView> getPFCompDocumentList() throws RemoteException, OperazioneAnagrafeManagerException {
    	return getOperazioneAnagrafeManager().getPFCompDocumentList(bancaId, true);
    }

    public Hashtable getCompatibleTipoSoggetto() throws InformazioneManagerException, RemoteException {
        return getGeograficaValidatorImpl().getCompatibleTipoSoggetto();
    }

    public Citta getCittaForCab(final String cab) throws InformazioneManagerException, RemoteException {
        return getGeograficaValidatorImpl().getCittaForCab(cab);
    }

    public Long getSoggettoIdForDatiFiscali(final String causale, final String valoreDatiFiscal) throws RemoteException {
        return getGeograficaValidatorImpl().getSoggettoIdForDatiFiscali(causale, valoreDatiFiscal);
    }

    public Collection getSoggettoIdsForDatiFiscali(final String causale, final String valoreDatiFiscal) throws InformazioneManagerException, RemoteException {
        return getGeograficaValidatorImpl().getSoggettoIdsForDatiFiscali(causale, valoreDatiFiscal);
    }

    public Collection getCompatibleMotivi(final Long tipoSoggettoId, final Long tipoSocietaId) throws InformazioneManagerException, RemoteException {
        return getGeograficaValidatorImpl().getCompatibleMotivi(tipoSoggettoId, tipoSocietaId);
    }

    public boolean isExistsDatiFiscali(final String code, final String causale) throws RemoteException {
        return getGeograficaValidatorImpl().isExistsDatiFiscali(code, causale);
    }

    public String getPresso() throws RemoteException {
        try {
            return IntestatazioneManagerFactory.getInstance().getIntestatazioneManager().getIntestatazioneString(bancaId);
        } catch (final IntestatazioneException e) {
            log4Debug.severeStackTrace(e);
            throw new RemoteException(e.getMessage());
        }
    }

    public Collection getCompatibleTipoSocieta(final Long tipoSoggettoId) throws InformazioneManagerException, RemoteException {
        return getOperazioneAnagrafeManager().getCompatibleTipoSocieta(tipoSoggettoId);
    }

    public String getDatiFiscali(final Long soggettoId, final String motiv) throws GestoreDatiFiscaliException, RemoteException {
        return getGestoreAnagrafeImpl().getDatiFiscali(soggettoId, motiv);
    }

    public Collection getLinkedSoggetto(final String tipoCollegamento) throws GestoreCollegamentoException, RemoteException {
        return getGestoreAnagrafeImpl().getLinkedSoggetto(bancaId, tipoCollegamento);
    }

    public Collection getCompatibleTipoIntermediari() throws OperazioneAnagrafeManagerException, RemoteException {
        return getOperazioneAnagrafeManager().getCompatibleTipoIntermediari();
    }

    public String getValoreCodiciSoggetto(final Long soggettoId, final String motivoCausale) throws GestoreCodiciSoggettoException, RemoteException {
        return getGestoreAnagrafeImpl().getValoreCodiciSoggetto(soggettoId, motivoCausale);
    }

    public String getIntestazioneString(final Long soggettoId) throws GestoreDatiAnagrafeException, RemoteException {
        try {
            return IntestatazioneManagerFactory.getInstance().getIntestatazioneManager().getIntestatazioneString(soggettoId);
        } catch (final IntestatazioneException e) {
            log4Debug.warnStackTrace(e);
            throw new GestoreDatiAnagrafeException(e.getMessage());
        }
    }

    public AnagrafeManager getAnagrafeManager() throws RemoteException {
        return anagrafeManager == null && anagrafeManagerHandle != null ?
        		anagrafeManager = (AnagrafeManager) anagrafeManagerHandle.getEJBObject() : anagrafeManager;
    }

    public GestoreAnagrafeImpl getGestoreAnagrafeImpl() throws RemoteException {
        return gestoreAnagrafeImpl == null && gestoreAnagrafeHandle != null ?
        		gestoreAnagrafeImpl = (GestoreAnagrafeImpl) gestoreAnagrafeHandle.getEJBObject() : gestoreAnagrafeImpl;
    }

    private GeograficaValidatorImpl getGeograficaValidatorImpl() throws RemoteException {
        return geograficaValidatorImpl == null && geograficaValidatorHandle != null ?
        		geograficaValidatorImpl = (GeograficaValidatorImpl) geograficaValidatorHandle.getEJBObject() : geograficaValidatorImpl ;
    }

    public Collection getCompatibleAttributiEsterni(final String tipoSoggetto) throws RemoteException {
        return getOperazioneAnagrafeManager().getCompatibleAttributiEsterni(tipoSoggetto);
    }

    private GeograficaValidatorImplHome getGeograficaValidatorImplHome() throws InformazioneManagerException {
		return (GeograficaValidatorImplHome)getHomeObject("GEOGRAFICAVALIDATORHOME","it.sella.anagrafe.implementation.GeograficaValidatorImplHome");
    }

    private AnagrafeManagerHome getAnagrafeManagerHome() throws InformazioneManagerException {
		return (AnagrafeManagerHome)getHomeObject("ANAGRAFEHOMENAME","it.sella.anagrafe.implementation.AnagrafeManagerHome");
    }

    private GestoreAnagrafeImplHome getGestoreAnagrafeImplHome() throws InformazioneManagerException {
		return (GestoreAnagrafeImplHome)getHomeObject("GESTOREANAGRAFEIMPLHOMENAME","it.sella.anagrafe.implementation.GestoreAnagrafeImplHome");
    }

    private OperazioneAnagrafeSessionHome getOperazioneAnagrafeSessionHome() throws InformazioneManagerException {
		return (OperazioneAnagrafeSessionHome)getHomeObject("OPERAZIONEANAGRAFEHOMENAME","it.sella.anagrafe.implementation.operazioneanagrafe.OperazioneAnagrafeSessionHome");
    }

    private Object getHomeObject(final String keyName, final String className) throws InformazioneManagerException {
    	try {
			return ResourceLookupHelper.getHomeObject(keyName,className);
		} catch (final ResourceLookupException e) {
			log4Debug.warnStackTrace(e);
			throw new InformazioneManagerException(e.getMessage());
		}
    }

    public Collection listInvalidDocumento(final String tipoDocumento) throws InformazioneManagerException, RemoteException {
        return getGeograficaValidatorImpl().listInvalidDocumento (tipoDocumento);
    }

    public void addInvalidDocumento(final InvalidDocumentoView invalidDocumentoView) throws InformazioneManagerException, RemoteException {
         getGeograficaValidatorImpl().addInvalidDocumento (invalidDocumentoView);
    }

    public void updateInvalidDocumento(final InvalidDocumentoView invalidDocumentoView) throws InformazioneManagerException, RemoteException {
        getGeograficaValidatorImpl().updateInvalidDocumento (invalidDocumentoView);
    }

    public void deleteInvalidDocumento(final Long id) throws InformazioneManagerException, RemoteException {
        getGeograficaValidatorImpl().deleteInvalidDocumento(id);
    }

    public Collection getAllCampagna() throws InformazioneManagerException, RemoteException {
        return getGeograficaValidatorImpl().getAllCampagna();
    }

    public void createOrigineClienteMaster(final OrigineClienteMasterView origineClienteMasterView) throws InformazioneManagerException, RemoteException {
        getGeograficaValidatorImpl().createOrigineClienteMaster(origineClienteMasterView);
    }

    public void updateOrigineClienteMaster(final OrigineClienteMasterView origineClienteMasterView) throws InformazioneManagerException, RemoteException {
        getGeograficaValidatorImpl().updateOrigineClienteMaster(origineClienteMasterView);
    }

    public void removeOrigineClienteMaster(final OrigineClienteMasterView origineClienteMasterView) throws InformazioneManagerException, RemoteException {
        getGeograficaValidatorImpl().removeOrigineClienteMaster(origineClienteMasterView);
    }

    public List getAttSezione(final String codiceSotto) throws InformazioneManagerException, RemoteException {
    	return getGeograficaValidatorImpl().getAttSezione(codiceSotto);
    }

    public List getAttClasse(final String classeCode) throws InformazioneManagerException, RemoteException {
    	return getGeograficaValidatorImpl().getAttClasse(classeCode);
    }
     public List<TAE> getTAE(final Long professioneId) throws RemoteException, InformazioneManagerException {
        return getGeograficaValidatorImpl().getTAE(professioneId);
    }
    public List<AlboProfessione> getAlboProfessiones(final Long tipoSoggettoId) throws RemoteException, InformazioneManagerException {
        return getGeograficaValidatorImpl().getAlboProfessiones(tipoSoggettoId);
    }
    /*public List<AlboProfessione> getAlboProfessiones() throws RemoteException, InformazioneManagerException {
        return getGeograficaValidatorImpl().getAlboProfessiones();
    }*/
    /**
     * This method is used to get all the modalita values to select the person who has done the verification of the document
     * @return Collection
     * @throws InformazioneManagerException
     * @throws RemoteException
     */
    public Collection getAllModalita() throws InformazioneManagerException, RemoteException {
        return getGeograficaValidatorImpl().getAllModalita();
    }
    
    /**
     * This method is used to get the nazione collection with storic equla to zero having prefisso
     */
    public Collection listNazioneWithPrefisso() throws InformazioneManagerException, RemoteException {
        return getGeograficaValidatorImpl().listNazioneWithPrefisso();
    }
   /* *//**
     * To get settore commerciale by passing atecocode
     * @param atecoCode
     * @return
     * @throws RemoteException
     * @throws InformazioneManagerException
     *//*
    public ClassificazioneView getSettoreCommerciale(final String classeCode) throws RemoteException, InformazioneManagerException {
        return getGeograficaValidatorImpl().getSettoreCommerciale(classeCode);
    }
    *//**
     * To get settore commerciale by passing taecode
     * @param taecode
     * @return
     * @throws RemoteException
     * @throws InformazioneManagerException
     *//*
    public ClassificazioneView getSettoreCommercialeByTAE(final String taeCode) throws RemoteException, InformazioneManagerException {
        return getGeograficaValidatorImpl().getSettoreCommercialeByTAE(taeCode);
    }*/
    
    /**
     * To get compatible FATCA Confermata. 
     * @param tipoSoggetto
     * @return
     * Collection<FatcaAZView>
     * @throws RemoteException, InformazioneManagerException 
     */
    public Collection<FatcaAZView> listFatcaConfermata(final String tipoSoggetto) throws RemoteException, InformazioneManagerException{
		return getGeograficaValidatorImpl().listFatcaConfermata(tipoSoggetto);
    }
    
    /**
     * This Method Returns all the available documents for PoteriFirma.
     * @return
     * @throws RemoteException
     * @throws InformazioneManagerException
     */
    public Collection listAllPoteriFirmaDocumento() throws RemoteException, InformazioneManagerException {
    	return getGeograficaValidatorImpl().listAllPoteriFirmaDocumento();
    }
    
    /**
     * This methos is to retrieve SettoreAttivita List by passing proffessione id
     * @param professioneId
     * @return
     * @throws RemoteException
     @throws InformazioneManagerException
     */
    public List<SettoreDiAttivita> getSettoreDiAttivitaByProffessioneId(final Long professioneId)throws RemoteException, InformazioneManagerException{
    	return getGeograficaValidatorImpl().getSettoreDiAttivitaByProffessioneId(professioneId);
    }
    /**
     * This method is to retrieve TAE list by passing professione and settore attivita id
     * @param professioneId
     * @param settoreAttivitaId
     * @return
     * @throws RemoteException
     * @throws InformazioneManagerException
     */
    public List<TAE> getTAEListByPorfessionAndSettoreAttivitaId(final Long professioneId,final Long settoreAttivitaId)throws RemoteException, InformazioneManagerException{
    	return getGeograficaValidatorImpl().getTAEListByPorfessionAndSettoreAttivitaId(professioneId,settoreAttivitaId);
    }
    
    /**
     * To get Channels of Communication
     * @return
     * @throws RemoteException
     * @throws InformazioneManagerException
     */
    public Collection<ClassificazioneView> getCanalePreferitoList() throws RemoteException, InformazioneManagerException {
		return getGeograficaValidatorImpl().getCanalePreferitoList();
    }
    
    /**
     * To Get Compatible Recapiti Canale List
     * @return
     * @throws RemoteException
     * @throws InformazioneManagerException
     */
    public Collection<RecapitiCanaleComptView> getCompatibleRecapitiCanale() throws RemoteException, InformazioneManagerException {
    	return getGeograficaValidatorImpl().getCompatibleRecapitiCanale();
    }
        
    /**
     * @param docCausale
     * @param bankId
     * @return
     * @throws InformazioneManagerException
     */
    public CompDocumentView getCompatibleDocumentView(final String docCausale, final Long bankId) throws InformazioneManagerException {
    	CompDocumentView compDocumentView = null;
    	final Map compatibleDocTable = anagrafeInformazioneCache.getCompatibleDocTable("COMP_DOC");
    	final String key = docCausale + "-" + bankId;
    	if(compatibleDocTable == null || !compatibleDocTable.containsKey(key)) { // Need to test not Contains
    		final Map<String, CompDocumentView> compDocTable = new CompDocumentDBAccessHelper().getPFCompatibleDocumentForAllBanks();
    		compDocumentView = compDocTable.get(key);
    		anagrafeInformazioneCache.putCompatibleDocTable("COMP_DOC", compDocTable);
    	}else {
    		compDocumentView = (CompDocumentView) compatibleDocTable.get(key);
    	}
    	log4Debug.debug("compDocumentView   ===========  ",compDocumentView);
		return compDocumentView;
    }
    
    
    
    public Collection<EgonView> listNazioneFromEGON() throws RemoteException, InformazioneManagerException {
    	try {
    		return AddressManagerFactory.getInstance().getAddressManager().getNazione("");
    	} catch (AddressException e) {
    		log4Debug.warnStackTrace(e);
    		throw new InformazioneManagerException(e.getMessage());
    	}
    }

}