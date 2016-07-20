package it.sella.anagrafe.webbean.censimento_pf;

import it.sella.anagrafe.InformazioneManagerException;
import it.sella.anagrafe.common.AlboProfessione;
import it.sella.anagrafe.common.Nazione;
import it.sella.anagrafe.common.SettoreDiAttivita;
import it.sella.anagrafe.common.TAE;
import it.sella.anagrafe.implementation.InformazioneManager;
import it.sella.anagrafe.util.ClassificazioneViewComparator;
import it.sella.anagrafe.util.CompDocumentiAggiuntiviComparator;
import it.sella.anagrafe.util.DocumentiAggiuntiviComparator;
import it.sella.anagrafe.util.SecurityHandler;
import it.sella.anagrafe.view.CompDocumentView;
import it.sella.anagrafe.webbean.CensimentoBean;
import it.sella.classificazione.ClassificazioneView;
import it.sella.util.Log4Debug;
import it.sella.util.Log4DebugFactory;

import java.rmi.RemoteException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;

public class CensimentoPFBean extends CensimentoBean {

    /**
	 *
	 */
	private static final long serialVersionUID = 1L;

	private static final Log4Debug log4Debug = Log4DebugFactory.getLog4Debug(CensimentoPFBean.class);

	public Collection collist = null;
    private static final String tipoSoggettoSecondLevelName = "Semplice";
    private Collection nazioneCollection;
    private Collection titolo1Collection;
    private Collection titolo2Collection;
    private Collection linguaCollection;
    private Collection patrimonialeCollection;
    private Collection statoCollection;
    private Collection sessoCollection;
    private Collection documentiCollection;
    private Collection eventiCollection;
    private Collection intermediariCollection;
    private Collection recaptiCollection;
    private Collection titolodistudioCollection;
    public Collection anagrafenazioneCollection;
    public Collection<Nazione>nazionePrefissoList;
    private Collection origineClienteCampgnaList = null;
    private  List<TAE> taeCollection = null;
    private  List<AlboProfessione> alboCollection = null;
	Hashtable nazioneListForNome = new Hashtable();
    public InformazioneManager informazioneManager;
    private final Map professioneMap = new HashMap();
    private List<SettoreDiAttivita> settoreAttivitaList;
    private List<TAE> taeList;
    private Collection canalePreferitoList;

    private final Map<Long, List<CompDocumentView>> compdocumentiMap = new HashMap<Long, List<CompDocumentView>>();
    private final Map intermediariMap = new HashMap();
    private Collection modalitaCollection;
    private Collection<String> nazioneNomesListFromEgon;
    private static final String iseLService = "it.sella.anagrafe.service.InvocationHandler";
    private static final String iseLServiceMethName = "executeService";
    private final Class<?>[] paramType = new Class[]{Object.class,String.class,Class[].class,Object[].class};

    public void setInformazioneManager(final InformazioneManager inManager) {
        informazioneManager = inManager;
    }
    
    public Long getBankId(){
    	final Class<?>[] paramType = new Class[]{Class.class,String.class,Class[].class,Object[].class};
    	final Object[] paramValue = new Object[]{SecurityHandler.class,"getLoginBancaId",new Class[]{},new Object[] {}};
    	Long bancaId = null;
        try {
        	bancaId = (Long)invokeISEService(iseLService, iseLServiceMethName, paramType, paramValue);
        } catch(final Exception e) {
            logExceptionSevere(e);
        }
        return bancaId;
    }
    public Collection getNazione() {
    	final Object[] paramValue = new Object[]{informazioneManager,"listNazione",new Class[]{},new Object[] {}};
        try {
        	nazioneCollection = nazioneCollection == null ? (Collection)invokeISEService(iseLService, iseLServiceMethName, paramType, paramValue) : nazioneCollection;
        } catch (final Exception e) {
        	logExceptionSevere(e);
        }
        return this.nazioneCollection;
    }

    public Nazione getNazione(final String nazioneNome) {
        if (this.nazioneListForNome.get(nazioneNome) == null) {
            try {
            	final Object[] paramValue = new Object[]{informazioneManager,"getNazione",new Class[]{String.class},new Object[] {nazioneNome}};
                final Nazione nazione = (Nazione) invokeISEService(iseLService, iseLServiceMethName, paramType, paramValue);
				if(nazione != null) {
					this.nazioneListForNome.put(nazioneNome,nazione);
				}
            } catch (final Exception e) {
            	logExceptionSevere(e);
            }
        }
        return (Nazione)this.nazioneListForNome.get(nazioneNome);
    }

    public Collection getAnagraficNazione() {
    	final Object[] paramValue = new Object[]{informazioneManager,"listAnagraficNazione",new Class[]{},new Object[] {}};
        try {
        	anagrafenazioneCollection = anagrafenazioneCollection == null ?
                			(Collection)invokeISEService(iseLService, iseLServiceMethName, paramType, paramValue) : anagrafenazioneCollection;
        } catch(final Exception e) {
        	logExceptionSevere(e);
        }
        return this.anagrafenazioneCollection;
    }

    public Collection getTitolo1() {
    	final Object[] paramValue = new Object[]{informazioneManager,"listTitolo1",new Class[]{},new Object[] {}};
        try {
        	titolo1Collection = titolo1Collection == null ? (Collection)invokeISEService(iseLService, iseLServiceMethName, paramType, paramValue) : titolo1Collection;
        } catch(final Exception e) {
        	logExceptionSevere(e);
        }
        return this.titolo1Collection;
    }

    public Collection getTitolo2() {
    	final Object[] paramValue = new Object[]{informazioneManager,"listTitolo2",new Class[]{},new Object[] {}};
        try {
        	titolo2Collection = titolo2Collection == null ? (Collection)invokeISEService(iseLService, iseLServiceMethName, paramType, paramValue) : titolo2Collection;
        } catch(final Exception e) {
        	logExceptionSevere(e);
        }
        return this.titolo2Collection;
    }

    public Collection getLingua() {
    	final Object[] paramValue = new Object[]{informazioneManager,"listLingua",new Class[]{},new Object[] {}};
        try {
        	linguaCollection = linguaCollection == null ? (Collection)invokeISEService(iseLService, iseLServiceMethName, paramType, paramValue) : linguaCollection;
        } catch(final Exception e) {
        	logExceptionSevere(e);
        }
        return linguaCollection;
    }

    public Collection getProfessione() {
    	final Object[] paramValue = new Object[]{informazioneManager,"listProfessione",new Class[]{},new Object[] {}};
    	final Long bankId = getBankId();
    	try {
        	if(professioneMap.get(bankId) == null){
        		final Collection professioneCollection = (Collection)invokeISEService(iseLService, iseLServiceMethName, paramType, paramValue);
        		if(professioneCollection != null){
        			professioneMap.put(bankId, professioneCollection);
        		}
        	}
        } catch(final Exception e) {
        	logExceptionSevere(e);
        }
        return (Collection)professioneMap.get(bankId);
    }

    public Collection getRegimePatrimoniale() {
    	final Object[] paramValue = new Object[]{informazioneManager,"listRegimePatrimoniale",new Class[]{},new Object[] {}};
        try {
        	patrimonialeCollection = patrimonialeCollection == null ?
                			(Collection)invokeISEService(iseLService, iseLServiceMethName, paramType, paramValue) : patrimonialeCollection;
        } catch(final Exception e) {
        	logExceptionSevere(e);
        }
        return patrimonialeCollection;
    }

    public Collection getStatoCivile() {
    	final Object[] paramValue = new Object[]{informazioneManager,"listStatoCivile",new Class[]{},new Object[] {}};
        try {
        	statoCollection = statoCollection == null ? 
        			(Collection)invokeISEService(iseLService, iseLServiceMethName, paramType, paramValue) : statoCollection;
        } catch(final Exception e) {
        	logExceptionSevere(e);
        }
        return statoCollection;
    }

    public Collection getCompatibleTipoDocumenti() {
    	final Object[] paramValue = new Object[]{informazioneManager,"getCompatibleTipoDocumeni",new Class[]{String.class},new Object[] {tipoSoggettoSecondLevelName}};
        try {
        	documentiCollection = documentiCollection == null ?	
        			(Collection)invokeISEService(iseLService, iseLServiceMethName, paramType, paramValue) : documentiCollection;
        	if ( documentiCollection != null && documentiCollection.size() > 1 ) {
            	final List documentList = new ArrayList(documentiCollection);
            	Collections.sort(documentList, new DocumentiAggiuntiviComparator());
            	documentiCollection = documentList;
        	}
        } catch(final Exception e) {
        	logExceptionSevere(e);
        }
        return documentiCollection;
    }

    public List<CompDocumentView> getCompatibleDocumenti() {
    	final Object[] paramValue = new Object[]{informazioneManager,"getPFCompDocumentList",new Class[]{},new Object[] {}};
        final Long bankId = getBankId();
    	try {
    		if(compdocumentiMap.get(bankId) == null){
    			List<CompDocumentView> compdocumentiColl = (List<CompDocumentView>)invokeISEService(iseLService, iseLServiceMethName, paramType, paramValue);
    			if ( compdocumentiColl != null && compdocumentiColl.size() > 1 ) {
                	final List documentList = new ArrayList(compdocumentiColl);
                	Collections.sort(documentList, new CompDocumentiAggiuntiviComparator());
                	compdocumentiColl = documentList;
            	}
    			if(compdocumentiColl != null){
    				compdocumentiMap.put(bankId, compdocumentiColl);
    			}
    		}

        } catch(final Exception e) {
        	logExceptionSevere(e);
        }
        return compdocumentiMap.get(bankId);
    }

    public Collection getCompatibleTipoEventi() {
    	final Object[] paramValue = new Object[]{informazioneManager,"getCompatibleTipoEventi",new Class[]{String.class},new Object[] {tipoSoggettoSecondLevelName}};
        try {
        	eventiCollection = eventiCollection == null ? 
        			(Collection)invokeISEService(iseLService, iseLServiceMethName, paramType, paramValue) : eventiCollection;
        } catch(final Exception e) {
        	logExceptionSevere(e);
        }
        if(eventiCollection != null && !eventiCollection.isEmpty()){
        	final List eventiList = new ArrayList(eventiCollection);
        	Collections.sort(eventiList, ClassificazioneViewComparator.DESCRIZIONE);
        	eventiCollection = eventiList;
        }
        return eventiCollection;
    }

    public Collection getCompatibleTipoIntermediari() {
    	final Object[] paramValue = new Object[]{informazioneManager,"getCompatibleTipoIntermediari",new Class[]{},new Object[] {}};
    	final Long bankId = getBankId();
    	try {
    		if(intermediariMap.get(bankId) == null){
    			intermediariCollection = (Collection) invokeISEService(iseLService, iseLServiceMethName, paramType, paramValue);
    			if(intermediariCollection != null){
    				intermediariMap.put(bankId, intermediariCollection);
    			}
    		}
    	} catch(final Exception e) {
    		logExceptionSevere(e);
    	}
    	return (Collection)intermediariMap.get(bankId);
    }

    public Collection getCompatibleTipoRecapiti() {
    	final Object[] paramValue = new Object[]{informazioneManager,"getCompatibleTipoRecapiti",new Class[]{String.class},new Object[] {tipoSoggettoSecondLevelName}};
        try {
        	recaptiCollection = recaptiCollection == null ?
                			(Collection)invokeISEService(iseLService, iseLServiceMethName, paramType, paramValue) : recaptiCollection;
        } catch(final Exception e) {
        	logExceptionSevere(e);
        }
        return recaptiCollection;
    }


    public Collection getSesso() {
    	final Object[] paramValue = new Object[]{informazioneManager,"listSesso",new Class[]{},new Object[] {}};
    	try {
    		sessoCollection = sessoCollection == null ? 
    				(Collection)invokeISEService(iseLService, iseLServiceMethName, paramType, paramValue) : sessoCollection;
        } catch(final Exception e) {
        	logExceptionSevere(e);
        }
        return sessoCollection;
    }


    public Collection getTitoloDiStudio() {
    	final Object[] paramValue = new Object[]{informazioneManager,"listTitoloDiStudio",new Class[]{},new Object[] {}};
        try {
        	titolodistudioCollection = titolodistudioCollection == null ?
                			(Collection)invokeISEService(iseLService, iseLServiceMethName, paramType, paramValue) : titolodistudioCollection;
        } catch(final Exception e) {
        	logExceptionSevere(e);
        }
        return titolodistudioCollection;
    }

    public String getPresso() {
    	final Object[] paramValue = new Object[]{informazioneManager,"getPresso",new Class[]{},new Object[] {}};
        String pressoDesc = null;
        try {
            pressoDesc = (String) invokeISEService(iseLService, iseLServiceMethName, paramType, paramValue);
        } catch(final Exception e) {
        	logExceptionSevere(e);
        }
        return pressoDesc;
    }

    public Collection getAllCampagna() {
    	final Object[] paramValue = new Object[]{informazioneManager,"getAllCampagna",new Class[]{},new Object[] {}};
        try {
        	origineClienteCampgnaList = origineClienteCampgnaList == null ?
                			(Collection)invokeISEService(iseLService, iseLServiceMethName, paramType, paramValue) : origineClienteCampgnaList;
        } catch(final Exception e) {
        	logExceptionSevere(e);
        }
        return origineClienteCampgnaList;
    }

    public void refreshCampgnaList() {
    	final Object[] paramValue = new Object[]{informazioneManager,"getAllCampagna",new Class[]{},new Object[] {}};
        try {
            origineClienteCampgnaList = (Collection) invokeISEService(iseLService, iseLServiceMethName, paramType, paramValue);
        } catch(final Exception e) {
        	logExceptionSevere(e);
        }
    }

    // Thiru

    public boolean resetLingua() {
    	final Object[] paramValue = new Object[]{informazioneManager,"listLingua",new Class[]{},new Object[] {}};
    	boolean isResetLingua = false;
        try {
        	linguaCollection = (Collection) invokeISEService(iseLService, iseLServiceMethName, paramType, paramValue);
        	isResetLingua = true;
        } catch(final Exception e) {
        	logExceptionSevere(e);
        }        
		return isResetLingua;
    }

    public boolean resetProfessione() {
    	boolean isResetProfessione = false;
        try {
        	professioneMap.remove(getBankId());
        	final Collection professione = getProfessione();
        	if(professione != null && !professione.isEmpty()){
        		isResetProfessione = true;
        	}
        } catch(final Exception e) {
        	logExceptionSevere(e);
        }        
		return isResetProfessione;
    }

    public boolean resetRegimePatrimoniale() {
    	final Object[] paramValue = new Object[]{informazioneManager,"listRegimePatrimoniale",new Class[]{},new Object[] {}};
    	boolean isResetRegime = false;
        try {
        	patrimonialeCollection = (Collection) invokeISEService(iseLService, iseLServiceMethName, paramType, paramValue);
        	isResetRegime = true;
        } catch(final Exception e) {
        	logExceptionSevere(e);
        }        
		return isResetRegime;
    }

    public boolean resetStatoCivile() {
    	final Object[] paramValue = new Object[]{informazioneManager,"listStatoCivile",new Class[]{},new Object[] {}};
    	boolean isResetStatoCivile = false;
        try {
        	statoCollection = (Collection) invokeISEService(iseLService, iseLServiceMethName, paramType, paramValue);
        	isResetStatoCivile = true;
        } catch(final Exception e) {
        	logExceptionSevere(e);
        }        
		return isResetStatoCivile;
    }

    public boolean resetSesso() {
    	final Object[] paramValue = new Object[]{informazioneManager,"listSesso",new Class[]{},new Object[] {}};
    	boolean isResetSesso = false;
    	try {
    		sessoCollection = (Collection) invokeISEService(iseLService, iseLServiceMethName, paramType, paramValue);
    		isResetSesso = true;
        } catch(final Exception e) {
        	logExceptionSevere(e);
        }        
		return isResetSesso;
    }

    public boolean resetCompatibleTipoDocumenti() {
    	final Object[] paramValue = new Object[]{informazioneManager,"getCompatibleTipoDocumeni",new Class[]{String.class},new Object[] {tipoSoggettoSecondLevelName}};
    	 boolean isResetCompaTipoDoc = false;
        try {
        	documentiCollection = (Collection) invokeISEService(iseLService, iseLServiceMethName, paramType, paramValue);
        	isResetCompaTipoDoc = true;
        } catch(final Exception e) {
        	logExceptionSevere(e);
        }       
		return isResetCompaTipoDoc;
    }

    public boolean resetCompatibleDocumenti() {
    	boolean isResetCompatibleDoc = false;
        try {
        	compdocumentiMap.remove(getBankId());
        	final List<CompDocumentView> compatibleDocumenti = getCompatibleDocumenti();
        	if(compatibleDocumenti != null && !compatibleDocumenti.isEmpty()){
        		isResetCompatibleDoc = true;
        	}
        } catch(final Exception e) {
        	logExceptionSevere(e);
        }        
		return isResetCompatibleDoc;
    }


    public boolean resetCompatibleTipoEventi() {
    	final Object[] paramValue = new Object[]{informazioneManager,"getCompatibleTipoEventi",new Class[]{String.class},new Object[] {tipoSoggettoSecondLevelName}};
    	boolean isResetCompatibleTipoEventi = false;
        try {
        	eventiCollection = (Collection) invokeISEService(iseLService, iseLServiceMethName, paramType, paramValue);
        	isResetCompatibleTipoEventi = true;
        } catch(final Exception e) {
        	logExceptionSevere(e);
        }        
		return isResetCompatibleTipoEventi;
    }

    public boolean resetCompatibleTipoIntermediari() {
    	 boolean isResetCompTipoInterm = false;
    	 try {
    		 intermediariMap.remove(getBankId());
         	final Collection compatibleTipoIntermediari = getCompatibleTipoIntermediari();
         	if(compatibleTipoIntermediari != null && !compatibleTipoIntermediari.isEmpty()){
         		isResetCompTipoInterm = true;
         	}
         } catch(final Exception e) {
        	 logExceptionSevere(e);
         }         
		 return isResetCompTipoInterm;
    }

    public boolean resetCompatibleTipoRecapiti() {
    	final Object[] paramValue = new Object[]{informazioneManager,"getCompatibleTipoRecapiti",new Class[]{String.class},new Object[] {tipoSoggettoSecondLevelName}};
    	boolean isResetCompTipoRecapiti = false;
        try {
        	recaptiCollection = (Collection) invokeISEService(iseLService, iseLServiceMethName, paramType, paramValue);
        	isResetCompTipoRecapiti = true;
        } catch(final Exception e) {
        	logExceptionSevere(e);
        }        
		return isResetCompTipoRecapiti;
    }

    public boolean resetTitoloDiStudio() {
    	final Object[] paramValue = new Object[]{informazioneManager,"listTitoloDiStudio",new Class[]{},new Object[] {}};
    	boolean isResetTitoloDiStudio = false;
        try {
        	titolodistudioCollection = (Collection) invokeISEService(iseLService, iseLServiceMethName, paramType, paramValue);
        	isResetTitoloDiStudio = true;
        } catch(final Exception e) {
        	logExceptionSevere(e);
        }        
		return isResetTitoloDiStudio;
    }

    public boolean resetAllCampagna() {
    	final Object[] paramValue = new Object[]{informazioneManager,"getAllCampagna",new Class[]{},new Object[] {}};
    	boolean isResetAllCampagna = false;
        try {
        	origineClienteCampgnaList = (Collection) invokeISEService(iseLService, iseLServiceMethName, paramType, paramValue);
        	isResetAllCampagna = true;
        } catch(final Exception e) {
        	logExceptionSevere(e);
        }        
		return isResetAllCampagna;
    }

    public boolean resetNazione() {
    	final Object[] paramValue = new Object[]{informazioneManager,"listAnagraficNazione",new Class[]{},new Object[] {}};
    	final Object[] paramValueforNazione = new Object[]{informazioneManager,"listNazione",new Class[]{},new Object[] {}};
    	boolean isResetNazione = false;
        try {
        	this.nazioneListForNome.clear();
        	anagrafenazioneCollection = (Collection) invokeISEService(iseLService, iseLServiceMethName, paramType, paramValue);
        	nazioneCollection = (Collection) invokeISEService(iseLService, iseLServiceMethName, paramType, paramValueforNazione);
        	isResetNazione = true;
        } catch(final Exception e) {
        	logExceptionSevere(e);
        }     	
		return isResetNazione;
    }

    public boolean resetTitolo() {
    	final Object[] paramValueTit1 = new Object[]{informazioneManager,"listTitolo1",new Class[]{},new Object[] {}};
    	final Object[] paramValueTit2 = new Object[]{informazioneManager,"listTitolo2",new Class[]{},new Object[] {}};
    	boolean isResetTitolo = false;
        try {
         	titolo1Collection = (Collection) invokeISEService(iseLService, iseLServiceMethName, paramType, paramValueTit1);
         	titolo2Collection = (Collection) invokeISEService(iseLService, iseLServiceMethName, paramType, paramValueTit2);
         	isResetTitolo = true;
        } catch(final Exception e) {
        	logExceptionSevere(e);
        }        
		return isResetTitolo;
    }
    public List<TAE> getTAE(final Long professioneId) {
    	final Object[] paramValue = new Object[]{informazioneManager,"getTAE",new Class[]{Long.class},new Object[] {professioneId}};
    	try {
    		log4Debug.info("get TAE Called in CensimentoPFBean Form JSp ==========",professioneId); 
        	taeCollection = (List<TAE>) invokeISEService(iseLService, iseLServiceMethName, paramType, paramValue);
        	log4Debug.info("taeCollection in CensimentoPFBean ",taeCollection.size());
        } catch(final Exception e) {
        	logExceptionSevere(e);
        }
        return taeCollection;
    }
    public List<AlboProfessione> getAlboProfessiones(final Long tipoSoggettoId) {
    	final Object[] paramValue = new Object[]{informazioneManager,"getAlboProfessiones",new Class[]{Long.class},new Object[] {tipoSoggettoId}};
    	try {
    		log4Debug.info("get ALBO Called in CensimentoPFBean Form JSp");
    		alboCollection =  alboCollection == null ? (List<AlboProfessione>)invokeISEService(iseLService, iseLServiceMethName, paramType, paramValue) : alboCollection;
        	log4Debug.info("alboCollection in CensimentoPFBean ",alboCollection.size());
    		 
        } catch(final Exception e) {
        	logExceptionSevere(e);
        }
        return alboCollection;
    }
    public boolean resetAlbo(final Long tipoSoggettoId) {
    	final Object[] paramValue = new Object[]{informazioneManager,"getAlboProfessiones",new Class[]{Long.class},new Object[] {tipoSoggettoId}};
    	try {
    		log4Debug.info("=========Resetting Albo=============");
    		alboCollection = (List<AlboProfessione>) invokeISEService(iseLService, iseLServiceMethName, paramType, paramValue);
    		return true;
    	} catch(final Exception e) {
    		logExceptionSevere(e);
    	}
    	return false;
    }
    //Added this code to Modalita
    public Collection getAllModalita() {
    	final Object[] paramValue = new Object[]{informazioneManager,"getAllModalita",new Class[]{},new Object[] {}};
        try {
        	modalitaCollection = modalitaCollection == null ?
                			(Collection)invokeISEService(iseLService, iseLServiceMethName, paramType, paramValue) : modalitaCollection;
        } catch(final Exception e) {
        	logExceptionSevere(e);
        }
        return modalitaCollection;
    }
    /**
     * This method is used to get the nazione collection with storic equla to zero having prefisso
     */
    public Collection<Nazione> getNazioneListWithPrefisso() {
    	final Object[] paramValue = new Object[]{informazioneManager,"listNazioneWithPrefisso",new Class[]{},new Object[] {}};
        try {
        	nazionePrefissoList = nazionePrefissoList == null ?
                			(Collection<Nazione>)invokeISEService(iseLService, iseLServiceMethName, paramType, paramValue) : nazionePrefissoList;
        } catch(final Exception e) {
        	logExceptionSevere(e);
        }
        return this.nazionePrefissoList;
    }
    
    public boolean resetPrefisso() {
    	final Object[] paramValue = new Object[]{informazioneManager,"listNazioneWithPrefisso",new Class[]{},new Object[] {}};
    	boolean isResetPrefisso = false;
    	try {
    		nazionePrefissoList = (Collection<Nazione>) invokeISEService(iseLService, iseLServiceMethName, paramType, paramValue);
    		isResetPrefisso=  true;
    	} catch(final Exception e) {
    		logExceptionSevere(e);
    	}
    	return isResetPrefisso;
    }
    /**
     * This methos is to retrieve SettoreAttivita List by passing proffessione id
     * @param professioneId
     * @return
     * @throws RemoteException
     @throws InformazioneManagerException
     */
    public List<SettoreDiAttivita> getSettoreDiAttivitaByProffessioneId(final Long professioneId) {
    	try {
    		log4Debug.debug("tiposoggetto for getSettoreDiAttivitaByProffessioneId==========================",professioneId);
    		final Object[] paramValue = new Object[]{informazioneManager,"getSettoreDiAttivitaByProffessioneId",new Class[]{Long.class},new Object[] {professioneId}};
    		settoreAttivitaList = (List<SettoreDiAttivita>)invokeISEService(iseLService, iseLServiceMethName, paramType, paramValue);

    	} catch(final Exception e) {
    		logExceptionSevere(e);
    	}
    	return settoreAttivitaList;
    }
    
    /**
     * This method is to retrieve TAE list by passing professione and settore attivita id
     * @param professioneId
     * @param settoreAttivitaId
     * @return
     * @throws RemoteException
     * @throws InformazioneManagerException
     */
    public List<TAE> getTAEBYSettoreDiAttivita(final Long professioneId,final Long settoreAttivitaId) {
    	try {
    		log4Debug.debug("tiposoggetto for getSettoreDiAttivitaByProffessioneId==========================",professioneId,settoreAttivitaId);
    		final Object[] paramValue = new Object[]{informazioneManager,"getTAEListByPorfessionAndSettoreAttivitaId",new Class[]{Long.class,Long.class},new Object[] {professioneId,settoreAttivitaId}};
    		taeList = (List<TAE>)invokeISEService(iseLService, iseLServiceMethName, paramType, paramValue);

    	} catch(final Exception e) {
    		logExceptionSevere(e);
    	}
    	return taeList;
    }
    
    /**
     * This Method Returns CanalePrferito (Channels of Communication)  List.
     * @return
     */
    public Collection<ClassificazioneView> getCanalePreferitoList() {
		final Object[] paramValue = new Object[]{informazioneManager,"getCanalePreferitoList",new Class[]{},new Object[] {}};
		
		try {
			canalePreferitoList = canalePreferitoList == null ?
					(Collection) invokeISEService(iseLService, iseLServiceMethName, paramType, paramValue) : canalePreferitoList;
			if(canalePreferitoList != null){
				final List canalePreferitoDummyList = new ArrayList(canalePreferitoList);
				Collections.sort(canalePreferitoDummyList, ClassificazioneViewComparator.ID);
				canalePreferitoList = canalePreferitoDummyList;
			}		
		} catch (final Exception e) {
			logExceptionSevere(e);
		}
		return canalePreferitoList;
	}
	
	
	/**
	 * This Method resets CanalePrferito (Channels of Communication)  List. 
	 * @return
	 */
	public boolean resetCanalePreferitoList() {
		boolean isResetCanalePreferito = false;
		try {
			final Object[] paramValue = new Object[]{informazioneManager,"getCanalePreferitoList",new Class[]{},new Object[] {}};
			canalePreferitoList = (Collection) invokeISEService(iseLService, iseLServiceMethName, paramType, paramValue);
			if(canalePreferitoList != null){
				final List canalePreferitoDummyList = new ArrayList(canalePreferitoList);
				Collections.sort(canalePreferitoDummyList, ClassificazioneViewComparator.ID);
				canalePreferitoList = canalePreferitoDummyList;
			}
			isResetCanalePreferito = true;
		} catch (final Exception e) {
			logExceptionSevere(e);
		}
		return isResetCanalePreferito;
	}
   
	
	
	public Collection<String> getNazioneNomesFromEGON() {
    	final Object[] paramValue = new Object[]{informazioneManager,"listNazioneFromEGON",new Class[]{},new Object[] {}};
        try {
        	nazioneNomesListFromEgon = nazioneNomesListFromEgon == null ? (Collection)invokeISEService(iseLService, iseLServiceMethName, paramType, paramValue) : nazioneNomesListFromEgon;
        } catch (final Exception e) {
        	logExceptionSevere(e);
        }
        return this.nazioneNomesListFromEgon;
    }
	
	/*public Collection<String> getProvinciaFromEGON() {
		try {
			//Map<String,String> loadProvincia
			return (List<String>) new NazioneDBAccessHelper().getProvinciaFromEGON();
		} catch (GestoreNazioneException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return null;
		
	}
	
	public Collection<String> getCap() {
		//Map<String,String> loadProvincia
		return (List<String>) new CapTableHandler().getCap();
		
	}*/
}