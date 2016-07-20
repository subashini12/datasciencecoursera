<%@ taglib uri="/statemachine.tld" prefix="sm"%>
<%@ page import=" java.util.*,
				it.sella.statemachine.View,
				it.sella.anagrafe.implementation.InformazioneManager,
				it.sella.anagrafe.util.*,
				it.sella.anagrafe.pf.*,
				it.sella.anagrafe.common.Nazione,
				it.sella.anagrafe.pf.DatiPrivacyPFView,
				it.sella.classificazione.*,
				it.sella.anagrafe.sm.censimentopf.ICensimentoPFConstants,
				it.sella.address.implementation.AddressAmbiguityView,
				it.sella.anagrafe.ICanaleUtilizzatoView,
				it.sella.anagrafe.logView.LogView"
%>				

<jsp:useBean id="CensBean" class="it.sella.anagrafe.webbean.censimento_pf.CensimentoPFBean" scope="application" />
<jsp:useBean id="CensBeanSess" class="it.sella.anagrafe.webbean.censimento_pf.CensimentoPFBean" scope="session" />

<%!
	private String buildAmbiguityIndirizzo(AddressAmbiguityView view) {
		StringBuffer output = new StringBuffer();
		output.append(getValue(view.getDugVia()));
		output.append(getValue(view.getNomeVia()));
		output.append(getValue(view.getOnlyNum()));
		return output.toString().trim();
	}

	private static String getValue(String input) {
		StringBuffer output = new StringBuffer();
		if (input != null)
			output.append(input.trim()).append(" ");
		return output.toString();
	}
	
	private boolean isEnableRecapitiOption(String tipoRecapiti,
			String riferimento) {
		if ("Posta Elettronica".equals(tipoRecapiti)) {
				return !new UtilHelper().isEightDigitNumericRiferimento(riferimento);
		}
		return true;
	}
	
%>

<%
	IndirizzoPFView indirizzoResidenzaView = null;
	IndirizzoPFView domicilioPFView = null;
	InformazioneManager informazioneManager = null;
	DatiPrivacyPFView datiPrivacyPFView = null;
	DatiPrivacyPFFiveLevelView datiPrivacyPFFiveLevelView = null;
	Hashtable stampaModuloHashtableView = null;
	
	View view = (View) session.getAttribute("view");
	String plMenuCheck = (String) view.getOutputAttribute("CENSIMENTOPF_ISFORPL");
	String strModifica = (String) view.getOutputAttribute("Modifica");
	if ("DUMMY".equals(strModifica))
		strModifica = null;
	
	String indietro = (String) view.getOutputAttribute("Indietro");
	String modificaRecapiti = (String) view.getOutputAttribute("RecapitiForModifica");
	String residenzaErrorMessage = (String) view.getOutputAttribute("IREErrorMessage");
	String domicilioErrorMessage = (String) view.getOutputAttribute("IDOErrorMessage");
	String recapitoErrorMessage = (String) view.getOutputAttribute("RecapitiErrorMessage");
	String canaleErrorMessage = (String)view.getOutputAttribute("CanalePreferitoErrorMessage");
	String privacyErrorMessage = (String) view.getOutputAttribute("DatiPrivacyErrorMessage");
	String stampaModuloPrivacyErrorMessage = (String) view.getOutputAttribute("StampaModuloPrivacyErrorMessage");
	String isSamePage = (String) view.getOutputAttribute("isSamePage");
	String loadedFirstTime = (String) view.getOutputAttribute("loadedFirstTime");
	Collection motivCollection = (Collection) view.getOutputAttribute("MOTIVI");
	String isPopped = (String) view.getOutputAttribute("POPPED");
	
	// Thiru
	Collection ireAmbiguiColl = (Collection) view.getOutputAttribute("IREAMBIGUICOL");
	Collection idoAmbiguiColl = (Collection) view.getOutputAttribute("IDOAMBIGUICOL");
	boolean isNormByBassed = false;
	
	AnagrafeHelper helper = new AnagrafeHelper();
	
	if (loadedFirstTime == null)
		loadedFirstTime = "yes";
	
	informazioneManager = (InformazioneManager) view.getOutputAttribute("IMANAGER");
	
	if (informazioneManager != null) {
		CensBean.setInformazioneManager(informazioneManager);
		CensBeanSess.setInformazioneManager(informazioneManager);
	}
	
	String IREIndirizzo = "";
	String IRECap = "";
	String IRECitta = "";
	String IREProvincia = "";
	String IRENazione = "ITALIA";
	String IRENorm = "";
	String IREEdificio = "";
	String IREPresso = "";
	
	String IDOIndirizzo = "";
	String IDOCap = "";
	String IDOCitta = "";
	String IDOProvincia = "";
	String IDONazione = "ITALIA";
	String IDONorm = "";
	String IDOEdificio = "";
	String IDOPresso = "";
	String prefissoCode ="";
	String nazioneNome = "";
	
	String tipoRecapito = "";
	String valoreRecapito = "";
	String riferimento = "";
	
	String level[] = new String[6];
	for (int i = 0; i < 6; i++)
		level[i] = "";
	
	//add by Pals
	String levelFive[] = new String[6];
	for (int i = 0; i < 6; i++)
		levelFive[i] = "";
	
	String stampaModuloStatus = "";
	String userBarCode = "";
	
	String isLivelloChecked = "";
	
	Hashtable residenzaHashtable = null;
	Hashtable domicilioHashtable = null;
	Hashtable recapitoHashtable = null;
	Hashtable privacyHashtable = null;			
	Hashtable stampaHashtable = null;
	
	if (privacyHashtable == null) {
		for (int i = 0; i < 6; i++)
			level[i] = null;
	}
	
	Hashtable privacyFiveLevelHashtable = null;
	if (privacyFiveLevelHashtable == null) {
		for (int i = 0; i < 6; i++)
			levelFive[i] = null;
	}
	
	
	Collection recapitiViewCollection = (Collection) view
			.getOutputAttribute(ICensimentoPFConstants.RECAPITI_PF_VIEW_SESSION);
	if (residenzaErrorMessage != null || domicilioErrorMessage != null
			|| recapitoErrorMessage != null
			|| privacyErrorMessage != null || "yes".equals(isSamePage) || canaleErrorMessage != null) {
		residenzaHashtable = (Hashtable) view.getOutputAttribute("IRE");
		if (residenzaHashtable != null) {
			IREIndirizzo = (String) residenzaHashtable.get("IREIndirizzo");
			IRECap = (String) residenzaHashtable.get("IRECap");
			IRECitta = (String) residenzaHashtable.get("IRECitta");
			IREProvincia = (String) residenzaHashtable.get("IREProvincia");
			IRENazione = (String) residenzaHashtable.get("IRENazione");
			IRENorm = (String) residenzaHashtable.get("IRENorm");
			IREEdificio = (String) residenzaHashtable.get("IREEdificio");
			IREPresso = (String) residenzaHashtable.get("IREPresso");
		}
		domicilioHashtable = (Hashtable) view.getOutputAttribute("IDO");
		if (domicilioHashtable != null) {
			IDOIndirizzo = (String) domicilioHashtable.get("IDOIndirizzo");
			IDOCap = (String) domicilioHashtable.get("IDOCap");
			IDOCitta = (String) domicilioHashtable.get("IDOCitta");
			IDOProvincia = (String) domicilioHashtable.get("IDOProvincia");
			IDONazione = (String) domicilioHashtable.get("IDONazione");
			IDONorm = (String) domicilioHashtable.get("IDONorm");
			IDOEdificio = (String) domicilioHashtable.get("IDOEdificio");
			IDOPresso = (String) domicilioHashtable.get("IDOPresso");
		}
		if (view.getOutputAttribute("RECAPITI_DETAILS") == null)
			recapitoHashtable = (Hashtable) view.getOutputAttribute("Recapiti");
		
		if (recapitoHashtable != null) {
			if (recapitoErrorMessage != null
					|| "RFM".equals(modificaRecapiti)
					|| "YES".equals(isPopped)) {
				tipoRecapito = (String) recapitoHashtable.get("tipoRecapito");
				valoreRecapito = (String) recapitoHashtable.get("valoreRecapito");
				riferimento = (String) recapitoHashtable.get("riferimento");
				final String []prefissoCodeWithNazione = StringHandler.getValueAfterSplitting((String) recapitoHashtable.get("prefissoId"));
				 if(prefissoCodeWithNazione.length == 2){
				  prefissoCode = prefissoCodeWithNazione[0].trim();
				  nazioneNome = prefissoCodeWithNazione[1].trim();
				  }
			}
		}
		if(view.getOutputAttribute("StampaModuloPrivacy")!= null){
			stampaHashtable =  (Hashtable)view.getOutputAttribute("StampaModuloPrivacy");
		}
		if(stampaHashtable != null){					
				stampaModuloStatus = (String) stampaHashtable.get("stampaModuloStatus");
				if("2".equals(stampaModuloStatus) || "4".equals(stampaModuloStatus)){
					userBarCode = (String) stampaHashtable.get("userBarCode");
				}
		}
	
		privacyHashtable = (Hashtable) view.getOutputAttribute("DatiPrivacy");
	
		if (privacyHashtable != null) {
	
			level[0] = (String) privacyHashtable.get("livello1");
			level[1] = (String) privacyHashtable.get("livello2");
			level[2] = (String) privacyHashtable.get("livello3");
			level[3] = (String) privacyHashtable.get("livello4");
			level[4] = (String) privacyHashtable.get("livello5");
			level[5] = (String) privacyHashtable.get("livello6");
	
		}
		// added by pals
		privacyFiveLevelHashtable = (Hashtable) view.getOutputAttribute("DatiPrivacyFiveLevel");
	
		if (privacyFiveLevelHashtable != null) {
			levelFive[0] = (String) privacyFiveLevelHashtable.get("livelloFive1");
			levelFive[1] = (String) privacyFiveLevelHashtable.get("livelloFive2");
			levelFive[2] = (String) privacyFiveLevelHashtable.get("livelloFive3");
			levelFive[3] = (String) privacyFiveLevelHashtable.get("livelloFive4");
			levelFive[4] = (String) privacyFiveLevelHashtable.get("livelloFive5");
			levelFive[5] = (String) privacyFiveLevelHashtable.get("livelloFive6");
		}
	
	} else if ("M".equals(strModifica) || indietro != null) {
		datiPrivacyPFView = (DatiPrivacyPFView) view.getOutputAttribute(ICensimentoPFConstants.DATI_PRIVACY_PF_VIEW_SESSION);
		datiPrivacyPFFiveLevelView = (DatiPrivacyPFFiveLevelView) view.getOutputAttribute(ICensimentoPFConstants.DATI_PRIVACY_PF_FIVELEVEL_VIEW_SESSION);
	
		if (datiPrivacyPFFiveLevelView != null) {
			datiPrivacyPFView = null;
		}
		if (datiPrivacyPFView != null) {
			level[0] = datiPrivacyPFView.getLivello1();
			level[1] = datiPrivacyPFView.getLivello2();
			level[2] = datiPrivacyPFView.getLivello3();
			level[3] = datiPrivacyPFView.getLivello4();
			level[4] = datiPrivacyPFView.getLivello5();
			level[5] = datiPrivacyPFView.getLivello6();
		}
	
		if (datiPrivacyPFFiveLevelView != null) {
			levelFive[0] = datiPrivacyPFFiveLevelView.getLivello1();
			levelFive[1] = datiPrivacyPFFiveLevelView.getLivello2();
			levelFive[2] = datiPrivacyPFFiveLevelView.getLivello3();
			levelFive[3] = datiPrivacyPFFiveLevelView.getLivello4();
			levelFive[4] = datiPrivacyPFFiveLevelView.getLivello5();
			levelFive[5] = datiPrivacyPFFiveLevelView.getProfil();
		}
	
		indirizzoResidenzaView = (IndirizzoPFView) view.getOutputAttribute(ICensimentoPFConstants.INDIRIZZO_RESIDENZA_PF_VIEW_SESSION);
		if (indirizzoResidenzaView != null) {
			IREIndirizzo = indirizzoResidenzaView.getIndirizzo();
			if (indirizzoResidenzaView.getCap() != null)
				IRECap = indirizzoResidenzaView.getCap().getCap();
			else
				IRECap = indirizzoResidenzaView.getCapCode();
			if (indirizzoResidenzaView.getCitta() != null)
				IRECitta = indirizzoResidenzaView.getCitta().getCommune();
			else
				IRECitta = indirizzoResidenzaView.getCittaCommune();
			if (indirizzoResidenzaView.getProvincia() != null)
				IREProvincia = indirizzoResidenzaView.getProvincia().getSigla();
			else
				IREProvincia = indirizzoResidenzaView.getProvinciaSigla();
			if (indirizzoResidenzaView.getNazione() != null
					&& indirizzoResidenzaView.getNazione().getNome() != null)
				IRENazione = indirizzoResidenzaView.getNazione().getNome().trim();
			if(indirizzoResidenzaView.getEdificio() !=null){
				IREEdificio = indirizzoResidenzaView.getEdificio();
			}
			if(indirizzoResidenzaView.getPresso() !=null){
				IREPresso = indirizzoResidenzaView.getPresso();
			}
		}
		/* domicilioPFView = (IndirizzoPFView) view.getOutputAttribute(ICensimentoPFConstants.INDIRIZZO_DOMICILIO_PF_VIEW_SESSION);
		if (domicilioPFView != null) {
			IDOIndirizzo = domicilioPFView.getIndirizzo();
			if (domicilioPFView.getCap() != null)
				IDOCap = domicilioPFView.getCap().getCap();
			else
				IDOCap = domicilioPFView.getCapCode();
			if (domicilioPFView.getCitta() != null)
				IDOCitta = domicilioPFView.getCitta().getCommune();
			else
				IDOCitta = domicilioPFView.getCittaCommune();
			if (domicilioPFView.getProvincia() != null)
				IDOProvincia = domicilioPFView.getProvincia().getSigla();
			else
				IDOProvincia = domicilioPFView.getProvinciaSigla();
			if (domicilioPFView.getNazione() != null
					&& domicilioPFView.getNazione().getNome() != null)
				IDONazione = domicilioPFView.getNazione().getNome().trim(); 
		} */
	}
	if (IRENazione == null || "".equals(IRENazione))
		IRENazione = "ITALIA";
	if (IDONazione == null || "".equals(IDONazione))
		IDONazione = "ITALIA";
	
	domicilioPFView = (IndirizzoPFView) view.getOutputAttribute(ICensimentoPFConstants.INDIRIZZO_DOMICILIO_PF_VIEW_SESSION);
	if (domicilioPFView != null) {
		IDOIndirizzo = domicilioPFView.getIndirizzo();
		if (domicilioPFView.getCap() != null)
			IDOCap = domicilioPFView.getCap().getCap();
		else
			IDOCap = domicilioPFView.getCapCode();
		if (domicilioPFView.getCitta() != null)
			IDOCitta = domicilioPFView.getCitta().getCommune();
		else
			IDOCitta = domicilioPFView.getCittaCommune();
		if (domicilioPFView.getProvincia() != null)
			IDOProvincia = domicilioPFView.getProvincia().getSigla();
		else
			IDOProvincia = domicilioPFView.getProvinciaSigla();
		if (domicilioPFView.getNazione() != null
				&& domicilioPFView.getNazione().getNome() != null)
			IDONazione = domicilioPFView.getNazione().getNome().trim();
		if(domicilioPFView.getEdificio() !=null){
			IDOEdificio = domicilioPFView.getEdificio();
		}
		if(domicilioPFView.getPresso() !=null){
			IDOPresso = domicilioPFView.getPresso();
		}
	}
	stampaModuloHashtableView = (Hashtable) view.getOutputAttribute(ICensimentoPFConstants.STAMPA_MODULO_PRIVACY_PF_VIEW_SESSION);
	if(stampaModuloHashtableView != null){					
		stampaModuloStatus = (String) stampaModuloHashtableView.get("stampaModuloStatus");
		if("2".equals(stampaModuloStatus) || "4".equals(stampaModuloStatus)){
			userBarCode = (String) stampaModuloHashtableView.get("userBarCode");
		}
	}
	
	final Collection<ClassificazioneView> canalePreferitoList = CensBean.getCanalePreferitoList();
	
	final Collection<SoggettoRecapitiView> telCellulareDataList = view.getOutputAttribute("TEL_CELLULARE_DATA") != null ? (Collection<SoggettoRecapitiView>)view.getOutputAttribute("TEL_CELLULARE_DATA") : null;
	final Collection<SoggettoRecapitiView> telFissoDataList = view.getOutputAttribute("TEL_FISSO_DATA") != null ? (Collection<SoggettoRecapitiView>)view.getOutputAttribute("TEL_FISSO_DATA") : null;
	final Collection<SoggettoRecapitiView> emailDataList = view.getOutputAttribute("CANALE_EMAIL_DATA") != null ? (Collection<SoggettoRecapitiView>)view.getOutputAttribute("CANALE_EMAIL_DATA") : null;
	
	Long userSelCanaleId = 0L;
	String telCellulare = "";
	String telFisso ="";
	String canaleEmail = "";
	String canaleTipoRecapId = "";
	final Map canlePreferDetails = (Map)view.getOutputAttribute("USER_CANALE_PREFERITO");
	
	if(canlePreferDetails != null) {
		userSelCanaleId = canlePreferDetails.get("CANALEPREFERITO") != null ? Long.valueOf((String)canlePreferDetails.get("CANALEPREFERITO")) : 0L;
		telCellulare = canlePreferDetails.get("TEL_CELLULARE") != null ? (String)canlePreferDetails.get("TEL_CELLULARE") : "";
		telFisso = canlePreferDetails.get("TEL_FISSO") != null ? (String)canlePreferDetails.get("TEL_FISSO") : "";
		canaleEmail = canlePreferDetails.get("CANALE_EMAIL") != null ? (String)canlePreferDetails.get("CANALE_EMAIL") : "";
		canaleTipoRecapId = canlePreferDetails.get("TIPO_RECAP_ID") != null ?  (String)canlePreferDetails.get("TIPO_RECAP_ID") : "";
	}
	ICanaleUtilizzatoView canaleUtilizzatoView = (ICanaleUtilizzatoView)view.getOutputAttribute(ICensimentoPFConstants.CANALE_UTILIZZATO_PF_VIEW);
	
	final Boolean profilPrivacyApplicable =  view.getOutputAttribute("DATIPRIV_PROFIL_APPLICABLE") != null ? (Boolean) view.getOutputAttribute("DATIPRIV_PROFIL_APPLICABLE") : Boolean.FALSE;
	final DatiPrivacyPFFiveLevelView privFivelevelDisplay =  (DatiPrivacyPFFiveLevelView) view.getOutputAttribute("DATIPRIV_FIVELEVEL_DISPLAY");
	final String selectSelectedPrivacy = (String)view.getOutputAttribute("SHOW_SELECTED_PRIVACY");
	
	/* final LogView privacyLogView =  (LogView) view.getOutputAttribute("DATIPRIV_FIVELEVEL_LOGVIEW"); */
	
%>
<!-- ToolTip Changes -->
  <link rel="stylesheet" href="/css/Anagrafe/jquery-ui.css" />
  <script type="text/javascript" src="/script/Anagrafe/jquery-1.9.1.js"></script>
  <script type="text/javascript" src="/script/Anagrafe/jquery-ui.js"></script>
  <script type="text/javascript" src="/script/Anagrafe/jquery-combo.js"></script>

<script language="JavaScript">

  function disableAllButton(){
	for(i=0; i<document.IndirizziRecapitiPrivacy.elements.length; i++) {
     if(document.IndirizziRecapitiPrivacy.elements[i].type == "button" || 
		document.IndirizziRecapitiPrivacy.elements[i].type == "submit") {
		document.IndirizziRecapitiPrivacy.elements[i].disabled = true;
	 }
	}
  }
  
  function submitForm(){
	 var isFormSubmiitedObj =  document.IndirizziRecapitiPrivacy.isFormSubmiited;
   	 if(isFormSubmiitedObj.value != 'true'){
           <sm:includeIfEventAllowed eventName="Conferma" >
              document.IndirizziRecapitiPrivacy.action = "<sm:getEventMainURL/>";
               isFormSubmiitedObj.value ='true';
               document.IndirizziRecapitiPrivacy.submit() ;
           </sm:includeIfEventAllowed>
            return true;
      } else {
		 return false;
	  } 
  }

  function submitMe(checkString) {
	var isFormSubmiitedObj =  document.IndirizziRecapitiPrivacy.isFormSubmiited;
	if (checkString == "RecapitiAggiungi") {
     if (isFormSubmiitedObj.value != 'true') {
      <sm:includeIfEventAllowed eventName="RecapitiAggiungi">
         document.IndirizziRecapitiPrivacy.action = "<sm:getEventMainURL/>";
         document.IndirizziRecapitiPrivacy.submit() ;
      </sm:includeIfEventAllowed>
     } 
	} else if(checkString == "RecapitiModifica") {
	 if (isFormSubmiitedObj.value != 'true') {
      <sm:includeIfEventAllowed eventName="RecapitiModifica">
         document.IndirizziRecapitiPrivacy.action = "<sm:getEventMainURL/>";
         document.IndirizziRecapitiPrivacy.submit() ;
      </sm:includeIfEventAllowed>
     } 
	} else if(checkString == "RecapitiElimina") {
	 if (isFormSubmiitedObj.value != 'true') {
      <sm:includeIfEventAllowed eventName="RecapitiElimina">
         document.IndirizziRecapitiPrivacy.action = "<sm:getEventMainURL/>";
         document.IndirizziRecapitiPrivacy.submit() ;
      </sm:includeIfEventAllowed>
     } 
	} else if(checkString == "IRPIndietro") {
	 if (isFormSubmiitedObj.value != 'true') {
      <sm:includeIfEventAllowed eventName="IRPIndietro">
         document.IndirizziRecapitiPrivacy.action = "<sm:getEventMainURL/>";
         document.IndirizziRecapitiPrivacy.submit() ;
      </sm:includeIfEventAllowed>
     }  
	} else if(checkString == "IRPAnnulla") {
	 if (isFormSubmiitedObj.value != 'true') {
      <sm:includeIfEventAllowed eventName="IRPAnnulla">
         document.IndirizziRecapitiPrivacy.action = "<sm:getEventMainURL/>";
         document.IndirizziRecapitiPrivacy.submit() ;
      </sm:includeIfEventAllowed>
     } 
	} else if(checkString == "Annulla") {
	  if (isFormSubmiitedObj.value != 'true') {
       <sm:includeIfEventAllowed eventName="Annulla">
         document.IndirizziRecapitiPrivacy.action = "<sm:getEventMainURL/>";
         document.IndirizziRecapitiPrivacy.submit() ;
       </sm:includeIfEventAllowed>
      } 
	} 			
   }
	
   function submitForRicerca(checkString){
    var isFormSubmiitedObj =  document.IndirizziRecapitiPrivacy.isFormSubmiited;
    if (isFormSubmiitedObj.value != 'true') {
      <sm:includeIfEventAllowed eventName="GeograficaRicerca">
          document.forms["IndirizziRecapitiPrivacy"].elements["GEOGRAFICA_RICERCA_FOR"].value=checkString;
          document.IndirizziRecapitiPrivacy.action = "<sm:getEventMainURL/>";
          document.IndirizziRecapitiPrivacy.submit() ;
      </sm:includeIfEventAllowed>
    }  
   }
	
	function setIndirrizoValue(normalizedIndirrizo) {
		var indirriArray = new Array();
		indirriArray = normalizedIndirrizo.split('^');
		if(indirriArray[1] == "IRE" ) {
		  document.forms["IndirizziRecapitiPrivacy"].elements["IREIndirizzo"].value=indirriArray[0];
		} else if(indirriArray[1] == "IDO" ) {
		  document.forms["IndirizziRecapitiPrivacy"].elements["IDOIndirizzo"].value=indirriArray[0];
		}
	}
	
	function doFocus() { 
		document.forms["IndirizziRecapitiPrivacy"].elements["IREPresso"].focus(); 		
	} 
	
	function displayStampaRadio(){
		privacySelected.style.display = 'inline';		
	}
	
function selectStampaModuloSecond( userBarCodevalue , idOfRadio , anotherUserBarCodeText ) {
	    var  stampaModuloStatus = document.getElementsByName("stampaModuloStatus");
		if( userBarCodevalue.value.length ) {
	       document.getElementById(idOfRadio).checked = true;
	       if(document.getElementById(anotherUserBarCodeText)){
	        document.getElementById(anotherUserBarCodeText).value="";
	       }
	    }else {
		stampaModuloStatus[0].checked = true;
	    }
}
</script>

<table width="100%">
	<tr>
		<td width="100%" class="testoContatti">Anagrafica - Censimento Persona Fisica</td>
	</tr>
	<tr>
		<td align="right" class="testoContatti">* Dato Obbligatorio</td>
	</tr>
</table>
<br>

<% if (residenzaErrorMessage != null || domicilioErrorMessage != null
					|| recapitoErrorMessage != null
					|| privacyErrorMessage != null|| stampaModuloPrivacyErrorMessage != null || canaleErrorMessage != null) { %>
<table width="100%" border="1" cellspacing="0" cellpadding="5" bordercolor="#CCCCCC" align="center">
	<tr>
		<td class="titolotab" height="25" align="left">
			<img src="/img/h2o/triangolo.gif" width="25" height="22" hspace="10" align="absmiddle">
				Completare i dati mancanti e/o verificare i messaggi di avviso
		</td>
	</tr>
</table>
<br>
<% } %>

<% if (plMenuCheck != null ) { %>
<table width="100%" border="1" cellspacing="0" cellpadding="0" bordercolor="003366">
	<tr>
		<td height="31">
			<jsp:include page="/H2O/CensimentoPF/CensimentoPF.IndicatoreStato.jsp" />
		</td>
	</tr>
</table>
<br>
<br>
<% } %>
<style>
			.my-placeholder { color: #C0C0C0; }
			
</style>

<body  onLoad="doFocus();"> 
<FORM name="IndirizziRecapitiPrivacy" action="<sm:getMainURL/>" method="post" >
	
<% if (residenzaErrorMessage != null || "".equals(residenzaErrorMessage)) { %>
<table width="100%" border="1" cellspacing="0" cellpadding="5" bordercolor="#CCCCCC" align="center">
	<tr>
		<td class="titolotab" height="25" align="left">
			<img src="/img/h2o/triangolo.gif" width="25" height="22" hspace="10" align="absmiddle"><%=residenzaErrorMessage%>
		</td>
	</tr>
</table>
<br>
<%	} %> 

<% if (ireAmbiguiColl != null && ireAmbiguiColl.size() > 0 && 
			((AddressAmbiguityView) ireAmbiguiColl.iterator().next()).getOnlyNum() == null) {

%>
<table width="100%" border="1" cellspacing="0" cellpadding="5" bordercolor="#CCCCCC" align="center">
	<tr>
		<td class="titolotab" height="25" align="left">
		  <img src="/img/h2o/news.gif" width="25" height="22" hspace="10" align="absmiddle">
			<font color="BLACK">Attenzione: l?indirizzo digitato potrebbe non essere corretto! Confermare l?inserimento solo
								dopo aver verificato che corrisponda ad un indirizzo esistente.
			</font>
		</td>
	</tr>
</table>
<br>
<% } %> 

<% isNormByBassed = true; %>

<table width="100%" cellpadding="1" cellspacing="0">
	<TR>
		<TD class=VertSxAlta width="80%"><b>Forzare Indirizzo? </b></TD>
<% if (IRENorm == null || "".equals(IRENorm) || "true".equalsIgnoreCase(IRENorm)) { %>
		<TD class=VertDxAlta width="5%">
			<INPUT type=radio value="false" name="IRENorm">S
		</TD>
		<TD class=VertDxAlta width="5%">
			<INPUT type=radio value="true" name="IRENorm" checked="true">N
		</TD>
<%	} else { %>
		<TD class=VertDxAlta width="5%">
			<INPUT type=radio value="false" name="IRENorm" checked="true">S
		</TD>
		<TD class=VertDxAlta width="5%">
			<INPUT type=radio value="true" name="IRENorm">N
		</TD>
<%	} %>
	</TR>
</table>

<% if (!isNormByBassed) { %> 
	<INPUT type="hidden" value="true" name="IRENorm"> 
<% } %>
<table class="topH2O" width="100%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
		<TABLE width="100%" bgColor="white">
			<TR>
				<td class="titolotab" colSpan=3><b>Residenza</b></td>
			</TR>
			<TR>
				<TD class="VertSxAlta" width="30%">C/O (presso)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<a href='#' onclick='javascript:window.open("/Anagrafe/include/Presso.html", "_blank", "scrollbars=1,resizable=1,height=300,width=450");' title='quando compilare'>quando compilare?</a>
				</TD>
				<TD class="VertDxAlta" width="70%">
					<INPUT maxLength="45" size="50" id ="Presso" name="IREPresso" value="<%=IREPresso%>" class="testocombo" placeholder="Completare nel caso in cui si voglia ricevere la corrispondenza presso altra destinazione">
				</TD>
			</TR>
			<TR>
				<TD class="VertSxAlta" width="30%">* Nazione</TD>
				<TD class="VertDxAlta" width="70%">
					<input type="text" id="IRENazione" name=IRENazione  value="<%= IRENazione %>" class="testocombo">
				</TD>
			</TR>
			<TR>
				<TD class="VertSxAlta" width="30%">&nbsp;&nbsp;CAP</TD>
				<TD class="VertDxAlta" width="70%">
					<INPUT maxLength=5 size=12 id="IRECap" name=IRECap value="<%=IRECap%>" class="testocombo">
				</TD>
				
			</TR>
			<TR>
				<TD class="VertSxAlta" width="30%">&nbsp;&nbsp;Provincia</TD>
				<TD class="VertDxAlta" width="70%">
					<INPUT maxLength=2 size=2  id="IREProvincia" name=IREProvincia   value="<%=IREProvincia%>" class="testocombo">
				</TD>
				
			</TR>
			<TR>
				<TD class="VertSxAlta" width="30%">* Citt&agrave;</TD>
				<TD class="VertDxAlta" width="70%">
					<INPUT maxLength=40 size=50 id="IRECitta"   name=IRECitta value="<%=IRECitta%>" class="testocombo">
				</TD>
				
			</TR>
			<TR>
				<TD class="VertSxAlta" width="30%">* Indirizzo</TD>
				<TD class="VertDxAlta" width="70%">
					<INPUT maxLength="35" size="50" name="IREIndirizzo" value="<%=IREIndirizzo%>" class="testocombo">
				</TD>
				
			</TR>
			<TR>
				<TD class="VertSxAlta" width="30%"> Edificio (palazzina, interno, scala)</TD>
				<TD class="VertDxAlta" width="70%">
					<INPUT maxLength="45" size="50" name="IREEdificio" value="<%=IREEdificio%>" class="testocombo">
				</TD>
			</TR>
		</TABLE>
		</td>
	</tr>
</table>


<% if (residenzaErrorMessage != null && ireAmbiguiColl != null && ireAmbiguiColl.size() > 0) { %>
<br>
<table class="topH2O" width="100%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
		<TABLE width="100%" bgColor="white">
			<TR>
				<td class="titolotab" colSpan=4><b>Indirizzi alternativi proposti:</b></td>
			</TR>
			<TR>
				<TD class="VertSxAlta" width="1%"></TD>
				<TD class="VertSxAlta" width="60%"><b> INDIRIZZO </b></TD>
				<TD class="VertSxAlta" width="31%"><b> CITTA' </b></TD>
				<TD class="VertSxAlta" width="9%" align="center"><b> PROVINCIA </b>
				</TD>
			</TR>
<%		int size = ireAmbiguiColl.size();
		Iterator ireAmbiguiIterator = ireAmbiguiColl.iterator();
		String ambiguityIndirizzo = null;
		for (int i = 0; i < size; i++) {
			AddressAmbiguityView abmiguityView = (AddressAmbiguityView) ireAmbiguiIterator.next();
			ambiguityIndirizzo = buildAmbiguityIndirizzo(abmiguityView);
%>
			<TR>
				<TD class="VertDxAlta" width="1%">
					<input type="radio" name="IREAMBI" value="<%= ambiguityIndirizzo + "^" + "IRE" %>"
								onClick='setIndirrizoValue(this.value)'></input>
				</TD>
				<TD class="VertDxAlta" ="VertSxAlta" width="60%"><%=ambiguityIndirizzo%>&nbsp;</TD>
				<TD class="VertDxAlta" width="31%">
					<%= abmiguityView.getLocalita() != null ? abmiguityView.getLocalita() : ""%>&nbsp;
				</TD>
				<TD class="VertDxAlta" width="9%" align="center">
					<%= abmiguityView.getProvincia() != null ? abmiguityView.getProvincia()	: ""%>&nbsp;
				</TD>
			</TR>
<%		} %>
		</TABLE>
	  </td>
	</tr>
</table>
<% } %> 
<br>

<% if (!((helper.checkForMotiv(motivCollection, "ANTCI") || helper.checkForMotiv(motivCollection, "POSTE")) && !helper.isExistsuperiorMotivThanAntci(motivCollection))) { %>

<% 		if (domicilioErrorMessage != null  || "".equals(domicilioErrorMessage)) { %>
<table width="100%" border="1" cellspacing="0" cellpadding="5" bordercolor="#CCCCCC" align="center">
	<tr>
		<td class="titolotab" height="25" align="left">
			<img src="/img/h2o/triangolo.gif" width="25" height="22" hspace="10" align="absmiddle"><%=domicilioErrorMessage%>
		</td>
	</tr>
</table>
<br>
<% 		}
   }
%> 

<% if (idoAmbiguiColl != null && idoAmbiguiColl.size() > 0 && 
			((AddressAmbiguityView) idoAmbiguiColl.iterator().next()).getOnlyNum() == null ) {
%>
<table width="100%" border="1" cellspacing="0" cellpadding="5" bordercolor="#CCCCCC" align="center">
	<tr>
		<td class="titolotab" height="25" align="left">
			<img src="/img/h2o/news.gif" width="25" height="22" hspace="10" align="absmiddle">
				<font color="BLACK">
					Attenzione: l?indirizzo digitato potrebbe non essere corretto! Confermare l?inserimento solo
					dopo aver verificato che corrisponda ad un indirizzo esistente.
				</font>
		</td>
	</tr>
</table>
<br>
<%	} %>

<% isNormByBassed = true; %>

<table width="100%" cellpadding="1" cellspacing="0">
	<TR>
		<TD class=VertSxAlta width="80%"><b>Forzare Indirizzo? </b></TD>
<% 	if (IDONorm == null || "".equals(IDONorm) || "true".equalsIgnoreCase(IDONorm)) { %>
		<TD class=VertDxAlta width="5%">
			<INPUT type=radio value="false" name="IDONorm">S
		</TD>
		<TD class=VertDxAlta width="5%">
			<INPUT type=radio value="true" name="IDONorm" checked="true">N
		</TD>
<%	} else { %>
		<TD class=VertDxAlta width="5%">
			<INPUT type=radio value="false" name="IDONorm" checked="true">S
		</TD>
		<TD class=VertDxAlta width="5%">
			<INPUT type=radio value="true" name="IDONorm">N</TD>
<%	} %>
	</TR>
</table>

<% if (!isNormByBassed) { %> 
	<INPUT type="hidden" value="true" name="IDONorm"> 
<%	} %>

<table class="topH2O" width="100%" cellpadding="1" cellspacing="0">
<% if (!((helper.checkForMotiv(motivCollection, "ANTCI") || helper.checkForMotiv(motivCollection, "POSTE")) && !helper.isExistsuperiorMotivThanAntci(motivCollection))) { %>
	<tr>
		<td>
		<TABLE width="100%" bgColor="white">
			<TR>
				<Td class="titolotab"><b>NON COMPILARE "Domicilio" SE UGUALE a "Residenza"</b></TD>
			</TR>
		</TABLE>
		<TABLE width="100%" bgColor="white">
			<TR>
				<Td class="titolotab" colSpan=3><b>Domicilio</b></Td>
			</TR>
			<TR>
				<TD class="VertSxAlta" width="30%">C/O (presso)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<a href='#' onclick='javascript:window.open("/Anagrafe/include/Presso.html", "_blank", "scrollbars=1,resizable=1,height=300,width=450");' title='quando compilare'>quando compilare?</a>
				
				</TD>
				<TD class="VertDxAlta" width="70%">
					<INPUT maxLength="45" size="50" name="IDOPresso" value="<%=IDOPresso%>" class="testocombo" placeholder="Completare nel caso in cui si voglia ricevere la corrispondenza presso altra destinazione">
				</TD>
			</TR>
			<TR>
				<TD class="VertSxAlta" width="30%">* Nazione</TD>
				<TD class="VertDxAlta" width="70%">
					<input type="text" id="IDONazione" name=IDONazione  value="<%= IDONazione %>" class="testocombo">
				</TD>
			</TR>
			<TR>
				<TD class="VertSxAlta" width="30%">&nbsp;&nbsp;CAP</TD>
				<TD class="VertDxAlta" width="70%">
					<INPUT maxLength=5 id="IDOCap" name="IDOCap" value="<%=IDOCap%>" size="12" class="testocombo"></TD>
			</TR>
			<TR>
				<TD class="VertSxAlta" width="30%">&nbsp;&nbsp;Provincia</TD>
				<TD class="VertDxAlta" width="70%">
					<INPUT maxLength=2 id="IDOProvincia" name="IDOProvincia"  value="<%=IDOProvincia%>" size="2" class="testocombo">
				</TD>
			</TR>
			<TR>
				<TD class="VertSxAlta" width="30%">* Citt&agrave;</TD>
				<TD class="VertDxAlta" width="70%">
					<INPUT maxLength=150 size="50" id="IDOCitta" name="IDOCitta" value="<%=IDOCitta%>"  class="testocombo">
				</TD>
			</TR>
			<TR>
				<TD class="VertSxAlta" width="30%">* Indirizzo</TD>
				<TD class="VertDxAlta" width="70%">
					<INPUT maxLength="35" size="50" name="IDOIndirizzo" value="<%=IDOIndirizzo%>" class="testocombo">
				</TD>
			</TR>
			<TR>
				<TD class="VertSxAlta" width="30%"> Edificio (palazzina, interno, scala)</TD>
				<TD class="VertDxAlta" width="70%">
					<INPUT maxLength="45" size="50" name="IDOEdificio" value="<%=IDOEdificio%>" class="testocombo">
				</TD>
				
			</TR>
		</TABLE>
		</td>
	</tr>
</table>


<% if (domicilioErrorMessage != null && idoAmbiguiColl != null && idoAmbiguiColl.size() > 0) { %>
<br>
<table class="topH2O" width="100%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
		 <TABLE width="100%" bgColor="white">
			<TR>
				<td class="titolotab" colSpan=4><b>Indirizzi alternativi proposti:</b></td>
			</TR>
			<TR>
				<TD class="VertSxAlta" width="1%"></TD>
				<TD class="VertSxAlta" width="60%"><b> INDIRIZZO </b></TD>
				<TD class="VertSxAlta" width="31%"><b> CITTA' </b></TD>
				<TD class="VertSxAlta" width="9%" align="center"><b> PROVINCIA </b></TD>
			</TR>
<%		int size = idoAmbiguiColl.size();
		Iterator idoAmbiguiIterator = idoAmbiguiColl.iterator();
		String ambiguityIndirizzo = null;
		for (int i = 0; i < size; i++) {
			AddressAmbiguityView abmiguityView = (AddressAmbiguityView) idoAmbiguiIterator.next();
			ambiguityIndirizzo = buildAmbiguityIndirizzo(abmiguityView);
%>
			<TR>
				<TD class="VertDxAlta" width="1%">
					<input type="radio" name="IDOAMBI" value="<%= ambiguityIndirizzo + "^" + "IDO" %>"
							onClick='setIndirrizoValue(this.value)'></input>
				</TD>
				<TD class="VertDxAlta" width="60%"><%= ambiguityIndirizzo %>&nbsp;</TD>
				<TD class="VertDxAlta" width="31%">
					<%= abmiguityView.getLocalita() != null ? abmiguityView.getLocalita() : ""%>&nbsp;
				</TD>
				<TD class="VertDxAlta" width="9%" align="center">
					<%= abmiguityView.getProvincia() != null ? abmiguityView.getProvincia() : ""%>&nbsp;
				</TD>
			</TR>
<%		} %>
		 </TABLE>
		</td>
	</tr>
</table>
<% } %>
<br>

<% if (recapitoErrorMessage != null || "".equals(recapitoErrorMessage)) { %>
<table width="100%" border="1" cellspacing="0" cellpadding="5"
	bordercolor="#CCCCCC" align="center">
	<tr>
		<td class="titolotab" height="25" align="left">
			<img src="/img/h2o/triangolo.gif" width="25" height="22" hspace="10" align="absmiddle"><%=recapitoErrorMessage%>
		</td>
	</tr>
</table>
<br>
<% }
if (canaleErrorMessage != null || "".equals(canaleErrorMessage)) { %>
<table width="100%" border="1" cellspacing="0" cellpadding="5"
	bordercolor="#CCCCCC" align="center">
	<tr>
		<td class="titolotab" height="25" align="left">
			<img src="/img/h2o/triangolo.gif" width="25" height="22" hspace="10" align="absmiddle"><%=canaleErrorMessage%>
		</td>
	</tr>
</table>
<br>
<% } %>

<table class="topH2O" width="100%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
		<TABLE width="100%" bgColor="white" cellpadding="1" cellspacing="0">
			<TR>
				<TD class=titolotab width="30%" ><b>Recapiti</b></td>
				<TD class=titolotab width="70%" align="right" colSpan="3">
					<input type="button" name="Aggiungi" value="Aggiungi" style="cursor:hand"
							onClick="disableAllButton();submitMe('RecapitiAggiungi')" class="bottone">
				</TD>
			</TR>
			<TR>
				<TD class="VertSxAlta">* Tipo Recapito</TD>
				<TD class="VertDxAlta" colspan="3">
					<SELECT name=tipoRecapito id ="tipoRecapito" class="testocombo" style="width: 200px">
					<option selected value="--Select--">--Seleziona--</option>
				<%
				Collection<ClassificazioneView> recapitiCollection = CensBean.getCompatibleTipoRecapiti();
						 if(recapitiCollection != null) {
							for(ClassificazioneView classificazioneView : recapitiCollection) {
								String recapitiFromView = classificazioneView.getId()+ "^" + classificazioneView.getDescrizione();
								if( (recapitiFromView != null && recapitiFromView.equals(tipoRecapito)) ) {
					%>
					<Option selected value="<%=classificazioneView.getId()+ "^" + classificazioneView.getDescrizione() %>"><%= classificazioneView.getDescrizione()%></Option>
					<% 			} else {
					%>
					<Option value="<%=classificazioneView.getId()+ "^" + classificazioneView.getDescrizione()%>"><%=classificazioneView.getDescrizione()%></Option>
					<%			}
							}
						}
						
					%>
		    		</select>
				</TD>
			</TR>
			
			<TR >
	       	 	<TD rowspan="2" class="VertSxAlta">* Numero/e-mail ecc.</TD>
	        	<TD class="VertSxAlta" id ="PrefissoLabel" >* Prefisso internazionale&nbsp;</td>
	        	<TD class="VertSxAlta" id ="RecapitoLabel">* Recapito&nbsp; </td>
			</TR>
			<TR>
				<TD class="VertDxAlta" id ="PrefissoValue" >
    				<select name="prefissoId" id ="PrefissoLoadValue"  class="testocOmbo" style="width: 200px">
      				<option selected value="--Select--">--Seleziona--</option>
					<%
						Nazione nazione = CensBean.getNazione("ITALIA");
							if(nazione != null){
						
					if( (nazione.getPrefissoCode() != null && nazione.getPrefissoCode().equals(prefissoCode) && nazione.getNome().equals(nazioneNome))) {
					%>
					<Option selected value="<%=nazione.getPrefissoCode()+" - "+nazione.getNome()%>"><%=nazione.getPrefissoCode() + " - "+ nazione.getNome()%></Option>
					 <%			} else {
						 %>
					<Option value="<%=nazione.getPrefissoCode()+" - "+nazione.getNome()%>"><%=nazione.getPrefissoCode() + " - "+ nazione.getNome()%></Option>
					<%} 
					}%>
		 			<%
						 Collection<Nazione> nazioneColl = CensBean.getNazioneListWithPrefisso();
						 if(nazioneColl != null) {
							for(Nazione prefissoValues : nazioneColl) {
							if (!"ITALIA".equals(prefissoValues.getNome())) {
								if( (prefissoValues.getPrefissoCode() != null && prefissoValues.getPrefissoCode().equals(prefissoCode) && prefissoValues.getNome().equals(nazioneNome))) {
					%>
					<Option selected value="<%= prefissoValues.getPrefissoCode()+" - "+prefissoValues.getNome()%>"><%= prefissoValues.getPrefissoCode()+ " - "+ prefissoValues.getNome()%></Option>
					<% 			} else {
					%>
					<Option value="<%= prefissoValues.getPrefissoCode()+" - "+prefissoValues.getNome()%>"><%= prefissoValues.getPrefissoCode()+ " - "+ prefissoValues.getNome() %></Option>
					<%			}
								}
							}
						}
					%>
		    		</select>
				</TD>	
			<TD class="VertDxAlta" >
			  <input maxLength=100 name="valoreRecapito" value="<%=valoreRecapito%>" class="testocombo">
			</TD>
			</TR>
			
			<TR>
				<TD class="VertSxAlta">&nbsp;&nbsp;Note</TD>
				<TD class="VertDxAlta" colspan="3">
					<INPUT maxLength=100 name=riferimento value="<%=riferimento%>" class="testocombo">
				</TD>
			</TR>
		</TABLE>

<%	if (recapitiViewCollection != null) {
			ClassificazioneView tipoRecapitiView = null;
			Iterator recapitiIterator = recapitiViewCollection.iterator();
			int recapitiViewCollectionSize = recapitiViewCollection.size();
			SoggettoRecapitiView recapitiPFView = null;
			String recapitiDescription = "&nbsp;";
			String recapitiValoreRecapiti = "&nbsp;";
			String recapitiRiferimento = "&nbsp;";
			String recapitiPrefissoCode = "&nbsp;";
%>

		<TABLE bgcOlor="white" width="100%">
			<TR>
				<Td class="titolotab" colSpan=6><b>Elenco Recapiti già Rilasciati</b></Td>
			</TR>
			<TR>
				<td class=VertSxAlta width="2%">&nbsp;</td>
				<TD class="VertSxAlta" width="20%">Tipo Recapito</TD>
				<TD class="VertSxAlta" width="15%">Prefisso</TD>
				<TD class="VertSxAlta" width="15%">Numero/e-mail ecc.</TD>
				<TD class="VertSxAlta" width="20%">Note</TD>
				<TD class="VertSxAlta" align="right" width="28%"  >
					<input type="button" name="Modifica" 
						onClick="disableAllButton();submitMe('RecapitiModifica')" value="Modifica" style="cursor:hand" class="bottone">&nbsp;
					<input type="button" name="Elimina" onClick="disableAllButton();submitMe('RecapitiElimina')"
							value="Elimina" style="cursor:hand" class="bottone">
				</TD>
			</TR>
<%		for (int i = 0; i < recapitiViewCollectionSize; i++) {
				recapitiPFView = (SoggettoRecapitiView) recapitiIterator.next();
				if (recapitiPFView.getTipoRecapiti() != null) 
					tipoRecapitiView = recapitiPFView.getTipoRecapiti();
				recapitiDescription = tipoRecapitiView.getDescrizione();
				recapitiValoreRecapiti = recapitiPFView.getValoreRecapiti();
				recapitiPrefissoCode = recapitiPFView.getPrefissoCode();
				recapitiRiferimento = recapitiPFView.getRiferimento();
%>
			<TR>
				<TD class="VertDxAlta" width="0%">
<%				if (isEnableRecapitiOption(tipoRecapitiView.getCausale() , recapitiPFView.getRiferimento() )) { %>
				   <INPUT type=radio value=<%=i%> name="IndexOfRecapiti"> 
<%				} else { %>
				&nbsp; 
<%				} %>
				</TD>
				<TD class="VertDxAlta" width="30%"><%=recapitiDescription%>&nbsp;</TD>
				<TD class="VertDxAlta" width="20%"><%=recapitiPrefissoCode%>&nbsp;</TD>
				<TD class="VertDxAlta" width="20%"><%=recapitiValoreRecapiti%>&nbsp;</TD>
				<TD class="VertDxAlta" width="30%" colspan="2"><%=recapitiRiferimento%>&nbsp;</TD>
			</TR>
<%		} %>
		</TABLE>
<%	} %>
	
	<table bgcolor="white" width="100%">
		<tr>
			<td class="titolotab" colspan="6"><b>Canale di comunicazione preferito *</b></td>
		</tr>
		<tr>
		<% if (canalePreferitoList != null && !canalePreferitoList.isEmpty()) { 
			for (ClassificazioneView canaleView : canalePreferitoList) { 
			if (!"NessunaPreferenza".equals(canaleView.getCausale())) { %>
				<td class="VertSxAlta" width="20%">
				<div><input type="radio" name="canalePreferito" value="<%=canaleView.getId()%>" causale-data="<%=canaleView.getCausale()%>" <%=userSelCanaleId.equals(canaleView.getId()) ? "checked" : "" %>><%=canaleView.getDescrizione()%></div>
				<%if("TEL_CELL".equals(canaleView.getCausale())) { %>
					<div><select name="selTelCellulare" id="selTelCellulare">
						<option selected value="--Select--">--Seleziona--</option>
						<% if(telCellulareDataList != null && !telCellulareDataList.isEmpty())  {
							for(SoggettoRecapitiView recapView : telCellulareDataList) { 
								String profisso = "";
								if(recapView.getPrefissoCode() != null) {
									final String [] prefissoCodeList = StringHandler.getValueAfterSplitting(recapView.getPrefissoCode());
									profisso = prefissoCodeList[0].trim() + " - ";
								}
								if(telCellulare.equals(recapView.getValoreRecapiti())) { %>
									<option selected value="<%=recapView.getValoreRecapiti()%>" canaTipoRecap="<%=recapView.getTipoRecapiti().getId()%>"><%=profisso + recapView.getValoreRecapiti()%></option>
								<% }else  { %>
									<option value="<%=recapView.getValoreRecapiti()%>" canaTipoRecap="<%=recapView.getTipoRecapiti().getId()%>"><%=profisso + recapView.getValoreRecapiti()%></option>
						<% } } } %>
					</select></div>
				
				<% } else if ("TEL_FISSO".equals(canaleView.getCausale())) { %>
					<div><select name="selTelFisso" id="selTelFisso">
						<option selected value="--Select--">--Seleziona--</option>
						<% if(telFissoDataList != null && !telFissoDataList.isEmpty())  {
							for(SoggettoRecapitiView recapView : telFissoDataList) {
								String profisso = "";
								if(recapView.getPrefissoCode() != null) {
									final String [] prefissoCodeList = StringHandler.getValueAfterSplitting(recapView.getPrefissoCode());
									profisso = prefissoCodeList[0].trim() + " - ";
								}
							if(telFisso.equals(recapView.getValoreRecapiti())) { %>
								<option selected value="<%=recapView.getValoreRecapiti()%>" canaTipoRecap="<%=recapView.getTipoRecapiti().getId()%>"><%=profisso + recapView.getValoreRecapiti()%></option>
							<% }else  { %>
								<option value="<%=recapView.getValoreRecapiti()%>" canaTipoRecap="<%=recapView.getTipoRecapiti().getId()%>"><%=profisso + recapView.getValoreRecapiti()%></option>
						<% } } } %>
					</select></div>
				
				<% } else if ("EMAIL".equals(canaleView.getCausale())) { %>
					<div><select name="selEmail" id="selEmail">
						<option selected value="--Select--">--Seleziona--</option>
						<% if(emailDataList != null && !emailDataList.isEmpty())  {
							for(SoggettoRecapitiView recapView : emailDataList) { 
							if(canaleEmail.equals(recapView.getValoreRecapiti())) { %>
								<option selected value="<%=recapView.getValoreRecapiti()%>" canaTipoRecap="<%=recapView.getTipoRecapiti().getId()%>"><%=recapView.getValoreRecapiti()%></option>
							<% }else  { %>
								<option value="<%=recapView.getValoreRecapiti()%>" canaTipoRecap="<%=recapView.getTipoRecapiti().getId()%>"><%=recapView.getValoreRecapiti()%></option>
						<% } } } %>
					</select></div>
				
				<% } else { %>
					<div>&nbsp;</div>
				<% } %>
			</td>
	<%  } } } %>
	<td class="VertSxAlta" width="20%"><div><input type="radio" name="canalePreferito" value="0" causale-data="None" <%=userSelCanaleId.equals(0L) ? "checked" : "" %>>Nessuna Preferenza</div><div>&nbsp;</div></td>
	</tr>
	</table>
	<table bgcolor="white" width="100%">
		<tr>
			<td class="VertSxAlta" width="30%">Canale pi&ugrave; utilizzato (op. dispositive)</td>
			<td class="VertDxAlta"><%=canaleUtilizzatoView != null && canaleUtilizzatoView.getCanaleUtilizzato() != null ? canaleUtilizzatoView.getCanaleUtilizzato() : ""%></td>
		</tr>
	</table>
	</tr>
</table>
<input type="hidden" name="tipoRecapId" id= "canaleTipoRecapId" value="<%=canaleTipoRecapId%>">
<br>

<% if ( privacyErrorMessage != null || "".equals(privacyErrorMessage)) { %>
<table width="100%" border="1" cellspacing="0" cellpadding="5" bordercolor="#CCCCCC" align="center">
	<tr>
		<td class="titolotab" height="25" align="left">
			<img src="/img/h2o/triangolo.gif" width="25" height="22" hspace="10" align="absmiddle">
				<%=privacyErrorMessage%>
		</td>
	</tr>
</table>
<br>
<%	} %>

<table class="topH2O" width="100%" cellpadding="1" cellspacing="0">

<%	if (((datiPrivacyPFView != null) && (datiPrivacyPFView.getLivello1() != null)) || 
			((privacyHashtable != null) && (level[0] != null))) {
%>
	<tr>
		<td>
		<TABLE width="100%" bgColor="white" cellpadding="1" cellspacing="0">
			<TR>
				<TD class=titolotab colSpan=3><B>Dati Privacy *</B></TD>
			</TR>
			<!-- Used For Checking The datiPrivacyPFView IS Null -->
<% 			String livellomsg[] = new String[6];
			livellomsg[0] = "Consenso alla comunicazione e al trattamento dei dati personali per l'esecuzione delle operazioni e dei servizi bancari diversi da quelli indicati nel riquadro B dell'informativa.";
			livellomsg[1] = "Consenso alla comunicazione, da parte della banca, dei dati a società di rilevazione della qualità dei servizi erogati.";
			livellomsg[2] = "Consenso al trattamento, da parte della banca, dei dati a fini di informazioni commerciali, ricerche di mercato, offerte dirette di prodotti o servizi del gruppo. ";
			livellomsg[3] = "Consenso al trattamento, da parte della banca, dei dati a fini di informazioni commerciali, ricerche di mercato, offerte dirette di prodotti o servizi di società terze. ";
			livellomsg[4] = "Consenso alla comunicazione, da parte della banca, dei dati a società terze a fini di informazioni commerciali, ricerche di mercato, offerte dirette di loro prodotti.";
			livellomsg[5] = "Consenso al trattamento di dati sensibili.";

			String sixLevelStatus = "";
			String checkLivello = "";
			String notLivello = "";
			for (int i = 0; i < 6; i++) {
				checkLivello = "";
				notLivello = "";
				sixLevelStatus = "";

%>
			<TR>
				<TD class=VertSxAlta width="90%"><B><%=i + 1%>° consenso - </B><%=livellomsg[i]%></TD>
	<%			if (level[i] != null && "true".equals(level[i])) {
					 sixLevelStatus = "Si";
				} else if (level[i] != null && "false".equals(level[i])) {
					sixLevelStatus = "No";
				} 
%>
				<td class="VertDxAlta" width="10%" align="center"><%=sixLevelStatus%></td>
				<input type="hidden" name="livello<%=i+1%>" value=<%= level[i] %>>
			</TR>
			<TR>
<%			} %>
		</TABLE>
	   </td>
	</tr>
<%  } %>
	
	<!-- 	Five Level Dati Privacy    added by pals  -->
	
<%		
		boolean showFiveLevelsReadOnly = false;
		String fiveLeveldata[] = new String[5];
		for (int i = 0; i < 5; i++)
			fiveLeveldata[i] = "";
		if(profilPrivacyApplicable && privFivelevelDisplay != null) {
			fiveLeveldata[0] =  privFivelevelDisplay.getLivello1();
			fiveLeveldata[1] =  privFivelevelDisplay.getLivello2();
			fiveLeveldata[2] =  privFivelevelDisplay.getLivello3();
			fiveLeveldata[3] =  privFivelevelDisplay.getLivello4();
			fiveLeveldata[4] =  privFivelevelDisplay.getLivello5();
			showFiveLevelsReadOnly = true;
		}

		String fiveLivelloMsg[] = new String[6];
		fiveLivelloMsg[0] = "Consenso alla comunicazione e al trattamento dei <b>dati personali</b> per l'esecuzione delle operazioni e dei servizi bancari diversi da quelli nell'informativa per i quali non è necessario richiedere il consenso all'interessato";
		fiveLivelloMsg[1] = "Consenso alla conservazione della <b>cronistoria</b> delle attività precontrattuali";
		fiveLivelloMsg[2] = "Consenso al trattamento dei dati da parte della banca per promozione/vendita di prodotti/servizi (anche di terzi), rilevazione del grado di soddisfazione della clientela, ricerche di mercato";
		fiveLivelloMsg[3] = "Consenso alla comunicazione dei dati a soggetti terzi che svolgono per conto della banca attività di promozione/vendita di prodotti/servizi, rilevazione del grado di soddisfazione della clientela, ricerche di mercato";
		fiveLivelloMsg[4] = "Consenso al trattamento di <b>dati sensibili</b> al fine di consentire alla Banca l'esecuzione di disposizioni impartite dal cliente stesso che contengano dati \"sensibili\" (es.: ordini di pagamento dalla cui causale descrittiva e/o beneficiario siano desumibili dati relativi all'iscrizione a sindacati, partiti politici o altre associazioni, oppure allo stato di salute)";
		
		int[] orderOfLevel = new int[] {4,1,2,3};
		
		String [] toolTipMsg=new String[6];
		toolTipMsg[0]="";
		toolTipMsg[1]="In breve: Consenso alla conservazione della documentazione delle attività precontrattuali (es. preventivi, richiesta di prodotti poi non sottoscritti)";
		toolTipMsg[2]="In breve: Consenso a essere contattato per rilevare il grado di soddisfazione, per ricerche di mercato o per comunicazioni sull'offerta di prodotti o servizi";
		toolTipMsg[3]="In breve: Consenso a essere contattato per rilevare il grado di soddisfazione, per ricerche di mercato o per comunicazioni sull'offerta di prodotti o servizi (da società terze per conto di Banca Sella)";
		toolTipMsg[4]="In breve: Consenso al trattamento dei <b>dati sensibili</b> per dare esecuzione a servizi richiesti dal cliente (Questo consenso è necessario per mantenere attivo il contratto)";
		toolTipMsg[5]="In breve: Consenso al trattamento dei dati del cliente per permettere a Banca Sella di comprendere e conoscere al meglio le sue esigenze per garantirgli un'offerta personalizzata e proporgli solo prodotti o servizi adatti a lui";
		String fiveLevelStatus = "";
		
		if(profilPrivacyApplicable && showFiveLevelsReadOnly) {  %>
		<tr>
		<td>
			<table width="100%" bgColor="white" cellpadding="1" cellspacing="0">
				<tr>
					<td class=titolotab colSpan=3><B>Dati Privacy *</B></td>
				</tr>
				<%
					for (int i = 0; i < 5; i++) {
						fiveLevelStatus = "";
				%>		
				<TR>		
					<TD class="VertSxAlta" width="95%" colspan="2"><B><%=i + 1%>° consenso - </B> <%=fiveLivelloMsg[i]%> </TD>
					<TD class="VertDxAlta" width="5%" align="center">
					<% if( fiveLeveldata[i]!= null && "true".equals(fiveLeveldata[i]) ) { 
						fiveLevelStatus = "Si";
					 }  else if( fiveLeveldata[i]!= null && "false".equals(fiveLeveldata[i]) ){
						fiveLevelStatus = "No";
					} %>
					<%= fiveLevelStatus %></TD>
				</TR>		
				<%	} %>
			</table>
		<td>
		</tr>	
<% 		} 
		
		if(profilPrivacyApplicable) {
			fiveLivelloMsg[5] = "Consenso al trattamento dei dati per finalità di <b>profilazione</b>";
			orderOfLevel = new int[] {4,1,2,3,5};
		}

		String checkFiveLivello = "";
		String notFiveLivello = "";
%>
	<tr>
		<td>
		 <TABLE width="100%" bgColor="white" cellpadding="1" cellspacing="0">
			<TR>
				<TD class=titolotab colSpan=4><B> Nuovo Consenso Dati Privacy *</B></TD>
			</TR>
			<!-- Used For Checking The datiPrivacyPFView IS Null -->

			<TR>
				<TD class=VertSxAlta width="80%" colspan="1"><%=fiveLivelloMsg[0]%> </TD>
				<TD class=VertDxAlta width="15%" colspan="3" align="center">Si <input type="hidden" name=livelloFive1 value="true" /></TD>
			</TR>
<%

				for (int i : orderOfLevel) {
					checkFiveLivello = "";
					notFiveLivello = "";
%>	
			 <TR width="100%">
				<TD class=VertSxAlta width="82.5%"><%=fiveLivelloMsg[i]%> </TD>
				<TD class=VertSxAlta width="2.5%"><a class ="idcheck"
								title="<%=toolTipMsg[i]%>" ><img src="/img/h2o/news.gif"
									width="20" height="20" hspace="9" align="absmiddle"></a></TD>
<% 				if (levelFive[i] != null && "true".equals(levelFive[i])) {
					checkFiveLivello = "Checked";
					notFiveLivello = "";
					isLivelloChecked = "true";
				} else if (levelFive[i] != null && "false".equals(levelFive[i])) {
					checkFiveLivello = "";
					notFiveLivello = "Checked";
					isLivelloChecked = "true";
				}
				if(showFiveLevelsReadOnly && selectSelectedPrivacy == null) {
					isLivelloChecked = "";
					checkFiveLivello = "";
					notFiveLivello= "";
				}
%>
				<TD class=VertDxAlta width="7.5%" aligne=center>
					<INPUT type=radio id="livelloFive<%=i+1%>" onclick="displayStampaRadio();"
							value="true" name="livelloFive<%=i+1%>" <%= checkFiveLivello %>>Si
				</TD>
				<TD class=VertDxAlta width="7.5%" aligne=center>
					<INPUT type=radio id="livelloFive<%=i+1%>" onclick="displayStampaRadio();" 
						<%= notFiveLivello %> value="false" name="livelloFive<%=i+1%>">No
				</TD>
			</TR>
<%			} %>
		</TABLE>
		<%-- <% if(strModifica != null && privacyLogView != null) { 
				String dateOfOperation = privacyLogView.getDateOfOperation() != null ? new DateHandler().formatDate(privacyLogView.getDateOfOperation() ,"dd-MM-yyyy") : "";
		%>
		<table bgcolor="white" width="100%">
			<tr>
				<TD class=VertSxAlta width="40%"><b>Ultima variazione</b></TD>
				<TD class=VertDxAlta width="30%" align=center><%=privacyLogView.getCodiciDipendente() != null ? privacyLogView.getCodiciDipendente() : ""%></TD>
				<TD class=VertDxAlta width="30%" align=center><%=dateOfOperation %></TD>
			</tr>
		</table>
		<% } %> --%>
					
<% if (stampaModuloPrivacyErrorMessage != null && ! "".equals(stampaModuloPrivacyErrorMessage)) { %>

<table width="100%" border="1" cellspacing="0" cellpadding="5" bordercolor="#CCCCCC" align="center">
	<tr>
		<td class="titolotab" height="25" align="left">
			<img src="/img/h2o/triangolo.gif" width="25" height="22" hspace="10" align="absmiddle">
				<%= stampaModuloPrivacyErrorMessage %>
		</td>
	</tr>
</table>
<br>
<%	}
	String checkStampModulo = "";
%>
	<div id="privacySelected" style=<%= "".equals(isLivelloChecked) ? "display:none" : "display:inline"  %>>	
		<TABLE width="100%" bgColor="white" cellpadding="1" cellspacing="0">
			<TR>
				<TD class=titolotab colSpan=3><B> Stampa modulo privacy</B></TD>
			</TR>
			<TR>
				<TD class=VertDxAlta width="1%" colspan="1" aligne=center>
					<INPUT type=radio value="1" 
						<%= stampaModuloStatus == null || stampaModuloStatus.trim().length() == 0 || 
							"1".equals(stampaModuloStatus) ? "checked" : "" %> name="stampaModuloStatus" >
				</TD>
				<TD class=VertDxAlta width="99%" colspan="1" aligne=center>
					bar-code automatico (stampa del modulo e creazione sospeso in Contrattualistica - Busta 10)
				</TD>
			</TR>
			<TR>
				<TD class=VertDxAlta width="1%" aligne=center>
					<INPUT type=radio value="2" <%= "2".equals(stampaModuloStatus)? "checked" : "" %> name="stampaModuloStatus" id="stampaModuloStatus2">
				</TD>
				<TD class=VertDxAlta width="60%" aligne=center>
					bar-code manuale reperito da modulo in bianco (creazione sospeso in Contrattualistica - Busta 
					10 con bar-code digitato, senza produzione della stampa del modulo) o copertina 320/00
				</TD>					
				<TD class=VertDxAlta width="39%" aligne=center>
					<input type="text" size="20" name="userBarCode2" id="userBarCode2" maxlength="13" onBlur=" isDigit(this);" 
						onchange=" selectStampaModuloSecond(this,'stampaModuloStatus2' ,'userBarCode4'); " value="<%= "2".equals(stampaModuloStatus)&& !"".equals(userBarCode)? userBarCode : "" %>" >
				</TD>
			</TR>
			<sm:includeIfEventAllowed eventName="SospesoB10BarCodeStampRadio" eventDescription="SospesoB10BarCodeStampRadio">
				<TR>
					<TD class=VertDxAlta width="1%" colspan="1" aligne=center>
						<INPUT type=radio value="3" <%= "3".equals(stampaModuloStatus)? "checked" : "" %> name="stampaModuloStatus">
					</TD>
					<TD class=VertDxAlta width="99%" colspan="1" aligne=center>
						Non stampare (non è previsto nessun automatismo né per la stampa del modulo né per la generazione del sospeso)
					</TD>
				</TR>
			</sm:includeIfEventAllowed>
			<sm:includeIfEventAllowed eventName="SospesoPerModuloUnificato" eventDescription="SospesoPerModuloUnificato">
			   <TR>
				   <TD class=VertDxAlta width="1%" aligne=center>
					<INPUT type=radio value="4" <%= "4".equals(stampaModuloStatus)? "checked" : "" %> name="stampaModuloStatus" id="stampaModuloStatus4">
				   </TD>
				   <TD class=VertDxAlta width="60%" aligne=center>
					bar-code manuale reperito da etichetta bar-code applicata sul Modulo Unificato 1/2000
					(creazione sospeso in Contrattualistica - Busta 10 con bar-code digitato, senza produzione della
					stampa del modulo) 
				   </TD>					
				   <TD class=VertDxAlta width="39%" aligne=center>
					<input type="text" size="20" name="userBarCode4" maxlength="13" onBlur=" isDigit(this);" 
						onchange=" selectStampaModuloSecond(this,'stampaModuloStatus4','userBarCode2'); " value="<%= "4".equals(stampaModuloStatus)&& !"".equals(userBarCode)? userBarCode : "" %>" >
				 </TD>
			    </TR>
			</sm:includeIfEventAllowed>
		</TABLE>
	</div>
	</td>
	</tr>
<% } else { %>
	<INPUT type="hidden" name="IDOIndirizzo" value="">
	<INPUT type="hidden" name="IDOCap" value="">
	<INPUT type="hidden" name="IDOCitta" value="">
	<INPUT type="hidden" name="IDOProvincia" value="">
	<input type="hidden" name="IDONazione" value="">
	<input type="hidden" name="IDOEdificio" value="">
	<input type="hidden" name="IDOPresso" value="">
	<INPUT type="hidden" name="tipoRecapito" value="--Select--">
	<INPUT type="hidden" name="prefissoId" value="--Select--">
	<INPUT type="hidden" name="valoreRecapito" value="">
	<INPUT type="hidden" name="riferimento" value="">
<% } %>
</table>
<br>
<TABLE cellSpacing=0 cellPadding=1 width="100%" border=0>
	<TR>
		<TD width="25%" align="center">
<% if (strModifica != null) { %> 
			<input type="hidden" name="Modifica" value="M"> 
			<input type="button" name="IRPAnnulla" 
				onClick="disableAllButton();submitMe('IRPAnnulla')" value="Annulla" style="cursor:hand"> 
<% } else { %> 
			<input type="button" name="Annulla" 
				onClick="disableAllButton();submitMe('Annulla')" value="Annulla" style="cursor:hand"> 
<%	} %>
		</TD>
<%	if (strModifica == null) { %>
		<TD width="25%" align="center">
			<input type="button" name="IRPIndietro" 
				onClick="disableAllButton();submitMe('IRPIndietro')" value="Indietro" style="cursor:hand">
		</TD>
<%	} else { %>
		<TD width="25%" align="center">&nbsp;</TD>
<%	} %>
		<TD width="50%">
			<sm:includeIfEventAllowed eventName="Conferma" 	eventDescription="Conferma">
				<input type="Submit" name="<sm:getEventParamName/>" value="<sm:getEventParamValue/>" style="cursor:hand" onclick="disableAllButton();return submitForm()">
			</sm:includeIfEventAllowed>
		</TD>
	</TR>
</TABLE>
<input type="hidden" name="GEOGRAFICA_RICERCA_FOR" value="" />
<input type="hidden" name="isFormSubmiited" value="">
</FORM>
</body>

<script type="text/javascript">
$(function(){
	/* 	$(".idcheck").tooltip({ tooltipClass: "custom-tooltip-styling"});
		var tooltipClass = $( ".idcheck" ).tooltip( "option", "tooltipClass" );
		$( ".idcheck" ).tooltip( "option", "tooltipClass", "custom-tooltip-styling" ); */
		$(".idcheck").tooltip({
	        content: function () {
	            return $(this).prop('title');
	        }
	    });
	});
$(document).ready(function(){
	 $("#tipoRecapito").change(function() {
		 var tipoRecapito = $("#tipoRecapito").val();
		 if(tipoRecapito == null || tipoRecapito == "" || tipoRecapito == "--Select--") {
			 $("#PrefissoLoadValue").val("--Select--");
			 $("#PrefissoValue").hide();
			 $("#PrefissoLabel").hide();
		 } else {
			 var tipoRecapitoDesc = tipoRecapito.split("^");
			 if("Fax" == tipoRecapitoDesc[1] || "Tel. Fisso" == tipoRecapitoDesc[1] ||"Tel. Cellulare" == tipoRecapitoDesc[1]){
				 $("#PrefissoValue").show();
				 $("#PrefissoLabel").show();
			} else{
				$("#PrefissoLoadValue").val("--Select--");
				$("#PrefissoValue").hide();
			 	$("#PrefissoLabel").hide();
		 	 } 
		 }
	}).trigger("change");
	 
	 $('input[type=radio][name=canalePreferito]').on('change', function() {
		 var selObject = $('input:radio[name=canalePreferito]').filter(":checked");
		 var selValue = selObject.val();
		 var causaleData = selObject.attr('causale-data');
		 
		 if(causaleData == 'TEL_CELL') {
			 $('#selTelCellulare').attr('disabled', false);
			 $('#selTelFisso').val('--Select--');
			 $('#selTelFisso').attr('disabled', true);
			 $('#selEmail').val('--Select--');
			 $('#selEmail').attr('disabled', true);
			 
		 } else if(causaleData == 'TEL_FISSO') {
			 $('#selTelFisso').attr('disabled', false);
			 $('#selTelCellulare').val('--Select--');
			 $('#selTelCellulare').attr('disabled', true);
			 $('#selEmail').val('--Select--');
			 $('#selEmail').attr('disabled', true);
			 
		 } else if (causaleData == 'EMAIL') {
			 $('#selEmail').attr('disabled', false);
			 $('#selTelFisso').val('--Select--');
			 $('#selTelFisso').attr('disabled', true);
			 $('#selTelCellulare').val('--Select--');
			 $('#selTelCellulare').attr('disabled', true);
			 
		 } else {
			 $('#selTelCellulare').val('--Select--');
			 $('#selTelCellulare').attr('disabled', true);
			 
			 $('#selTelFisso').val('--Select--');
			 $('#selTelFisso').attr('disabled', true);
			 
			 $('#selEmail').val('--Select--');
			 $('#selEmail').attr('disabled', true);
			 $('#canaleTipoRecapId').val('');
		 }
	 }).trigger('change');
	 
	 $('#selTelCellulare').change(function(){
		 var selObj = $(this).find('option:selected');
		 var selVal = $(this).val();
		 if( selVal != '--Select--') {
			 $('#canaleTipoRecapId').val(selObj.attr('canaTipoRecap'));
		 } else {
			 $('#canaleTipoRecapId').val('');
		 }
	});
	
	$('#selTelFisso').change(function(){
		var selObj = $(this).find('option:selected');
		var selVal = $(this).val();
		if(selVal != '--Select--') {
			$('#canaleTipoRecapId').val(selObj.attr('canaTipoRecap'));
		} else {
			$('#canaleTipoRecapId').val('');
		}
	});
	
	$('#selEmail').change(function(){
		var selObj = $(this).find('option:selected');
		var selVal = $(this).val();
		if(selVal != '--Select--') {
			$('#canaleTipoRecapId').val(selObj.attr('canaTipoRecap'));
		}
	}).trigger('change');
	$(function() {
		$('input').placeholder({customClass:'my-placeholder'});
	});
});
</script>