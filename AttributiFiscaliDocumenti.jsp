<%@page import="it.sella.anagrafe.common.SettoreDiAttivita"%>
<%@ taglib uri = "/statemachine.tld" prefix="sm" %>

<%@ page import="java.util.Collection,
                 java.util.Hashtable,
                 java.util.Iterator,
                 it.sella.anagrafe.util.JspPageHelper,
                 java.text.SimpleDateFormat,
                 java.sql.Timestamp,
                 it.sella.statemachine.View,
                 it.sella.classificazione.ClassificazioneView,
                 it.sella.anagrafe.pf.AttributiEsterniPFView,
                 it.sella.anagrafe.pf.DatiFiscaliPFView,
                 it.sella.anagrafe.pf.DocumentoPFView,
                 it.sella.anagrafe.sm.censimentopf.ICensimentoPFConstants,
                 it.sella.anagrafe.common.Nazione,
                 it.sella.anagrafe.util.DateHandler,
                 it.sella.anagrafe.util.AnagrafeHelper,
                 java.util.List,
                 it.sella.anagrafe.sm.censimentopf.ICensimentoPFConstants,
                 it.sella.anagrafe.common.TAE,
                 it.sella.anagrafe.common.AlboProfessione,
                 it.sella.anagrafe.view.CompDocumentView,
                 it.sella.anagrafe.common.Citta,
                 it.sella.anagrafe.util.StringHandler" %>

<jsp:useBean  id="CensBean" class ="it.sella.anagrafe.webbean.censimento_pf.CensimentoPFBean" scope="application"/>

<%
    View view = (View)session.getAttribute("view");
    String modifica = (String)view.getOutputAttribute("Modifica");
   	String attributiErrorMessage = (String)view.getOutputAttribute("attributiErrorMessage");
	String datiFiscaleErrorMessage = (String)view.getOutputAttribute("datiFiscaleErrorMessage");
	String documentoErrorMessage = (String)view.getOutputAttribute("documentoErrorMessage");
	String documentoCSErrorMessage = (String)view.getOutputAttribute("documentoCSErrorMessage");
	String CSConformaWarningMessage = (String)view.getOutputAttribute("CS_ConformaWarningMessage");
	String CartaDocConformaWarningMessage = (String)view.getOutputAttribute("CartaDoc_ConformaWarningMessage");
	String RRPSWarningMessage = (String)view.getOutputAttribute("RRPSWarningMessage");
	String errorMessage = (String)view.getOutputAttribute("errorMessage");
	Collection motivCollection = (Collection)view.getOutputAttribute("MOTIVI");
    boolean isW8CertAllowed = ((Boolean)view.getOutputAttribute("IS_W8_CERT_ALLOWED")).booleanValue();
    boolean isW8iCertAllowed = ((Boolean)view.getOutputAttribute("IS_W8I_CERT_ALLOWED")).booleanValue();
    boolean isW9CertAllowed = ((Boolean)view.getOutputAttribute("IS_W9_CERT_ALLOWED")).booleanValue();
    String isAFDDatascanConvertion = (String) view.getOutputAttribute("isAFDDatascanConvertion");
    String isAFDRilasciatoDaConvertion = (String)view.getOutputAttribute("isAFDRilasciatoDaConvertion");
    boolean isAlterResidAllowed = ((Boolean)view.getOutputAttribute("IS_CONFIG_ALLOWED")).booleanValue();
    Hashtable attributiDetails = view.getOutputAttribute("attributiDetails") != null ? (Hashtable)view.getOutputAttribute("attributiDetails") : new Hashtable();
    String sesso = (String)attributiDetails.get("sesso") ;
    String titolo1 = (String)attributiDetails.get("titolo1") ;
    String titolo2 = (String)attributiDetails.get("titolo2") ;
    String titoloDiStudio = (String)attributiDetails.get("titoloDiStudio");
    String lingua = (String)attributiDetails.get("lingua") ;
    String professione = attributiDetails.get("professione")!=null &&!"".equals(attributiDetails.get("professione"))?(String)attributiDetails.get("professione"):null ;
    String statoCivile = (String)attributiDetails.get("statoCivile") ;
    String regimePatrimoniale = (String)attributiDetails.get("regimePatrimoniale") ;
	String cittadinanza = (String)attributiDetails.get("cittadinanza") ;
	String secondaCittadinanza = (String)attributiDetails.get("secondaCittadinanza") ;
    String nosconf = attributiDetails.get("nosconf") != null ? (String)attributiDetails.get("nosconf") : "true";
    String hiddenSconf = view.getInputAttribute("hiddenSconf") != null ? (String)view.getInputAttribute("hiddenSconf") : nosconf;
   // String attivita = (String)attributiDetails.get("attivita") ;
    //String attivita_descrizione = attivita != null && attivita.length() > 0 ? attivita+"^"+(String)view.getOutputAttribute("attivitaDescrizione") : "";
	// Thiru
	String settore = view.getInputAttribute("settore") != null ? (String) view.getInputAttribute("settore") : (String) attributiDetails.get("settore");
    String ramo = view.getInputAttribute("ramo") != null ? (String)view.getInputAttribute("ramo") : (String) attributiDetails.get("ramo");
    TAE tae = (TAE) attributiDetails.get("tae") ;
    final String taeVal = tae!=null && tae.getTaeDesc()!=null ? tae.getTaeDesc().trim() : "";
    
    SettoreDiAttivita attivita = (SettoreDiAttivita) attributiDetails.get("settattivita") ;
    String settoreCommerciale = attributiDetails.get("setcomm") != null ? (String)attributiDetails.get("setcomm"):"";
   	AlboProfessione albo = (AlboProfessione)attributiDetails.get("albo");
    String numero = (String)attributiDetails.get("numero") ;
    String ulteriori = (String)attributiDetails.get("ulteriori") ;
    String ident = attributiDetails.get("ident")  !=null ?(("Si".equals((String)attributiDetails.get("ident"))||"0".equals((String)attributiDetails.get("ident")))?"Si":"No"):"--Select--" ;
    String DataEmissioneWarningMessage = (String)view.getOutputAttribute("DataEmissioneWarningMessage");
    
    Hashtable datiFiscaliDetails = view.getOutputAttribute("datiFiscaliDetails") != null ? (Hashtable)view.getOutputAttribute("datiFiscaliDetails") : new Hashtable();
    String codiceFiscale = datiFiscaliDetails.get("codiceFiscale") != null ? (String)datiFiscaliDetails.get("codiceFiscale") : "";
    String partitaIva = datiFiscaliDetails.get("partitaIva") != null ? (String)datiFiscaliDetails.get("partitaIva") : "";
    boolean indicatoreRV = "on".equals(datiFiscaliDetails.get("indicatoreRV")) ? true : false;
    boolean indicatoreA97 = "on".equals(datiFiscaliDetails.get("indicatoreA97")) ? true : false;
   	boolean indicatoreA96 = "on".equals(datiFiscaliDetails.get("indicatoreA96")) ? true : false;
    
	String residenzaValutaria = datiFiscaliDetails.get("residenzaValutaria") != null ? (String)datiFiscaliDetails.get("residenzaValutaria") : "";
	String residenzaFiscale = datiFiscaliDetails.get("residenzaFiscale") != null ? (String)datiFiscaliDetails.get("residenzaFiscale") : "";
	boolean w8 = "on".equals(datiFiscaliDetails.get("w8")) ? true : false;
    boolean w8i = "on".equals(datiFiscaliDetails.get("w8i")) ? true : false;
    boolean w9 = "on".equals(datiFiscaliDetails.get("w9")) ? true : false;
    String codiceFiscaleEstero = datiFiscaliDetails.get("codiceFiscaleEstero") != null ? (String)datiFiscaliDetails.get("codiceFiscaleEstero") : "";
    String numeroSicurezzaSociale = datiFiscaliDetails.get("numeroSicurezzaSociale") != null ? (String)datiFiscaliDetails.get("numeroSicurezzaSociale") : "";
    String isUsOriginDatiIndirzzo = view.getOutputAttribute( ICensimentoPFConstants.ISUSORIGIN_DATIIINDIRZZ0 ) != null ? (String) view.getOutputAttribute( ICensimentoPFConstants.ISUSORIGIN_DATIIINDIRZZ0 ) : "";
    String isUsOriginAll = view.getOutputAttribute( ICensimentoPFConstants.ISUSORIGIN_ALL ) != null ? (String) view.getOutputAttribute( ICensimentoPFConstants.ISUSORIGIN_ALL ) : "";
    String isUsOriginCollegate = view.getOutputAttribute( "IS_US_COLLEGATE" ) != null ? (String) view.getOutputAttribute( "IS_US_COLLEGATE" ) : "";
    Collection<Nazione> nazioneCollection = CensBean.getNazione();
    
    String fatcaSoggettoUSA = datiFiscaliDetails.get("fatca_soggetto_usa") != null ? (String)datiFiscaliDetails.get("fatca_soggetto_usa") : "Non Calcolato";
    String fatcaStatus = datiFiscaliDetails.get("fatca_status") != null ? (String)datiFiscaliDetails.get("fatca_status") : "Non Calcolato";
    String presenzaDiIndizi = datiFiscaliDetails.get("presenza_indizi") != null ? (String)datiFiscaliDetails.get("presenza_indizi") : "Non Calcolato";
    presenzaDiIndizi = ("Y".equals(isUsOriginDatiIndirzzo) || "Y".equals(isUsOriginAll)) ? "Si" : (!"Non Calcolato".equals(presenzaDiIndizi) && !"Si".equals(presenzaDiIndizi)) ? "No" : presenzaDiIndizi;

	Hashtable documentoDetails = view.getOutputAttribute("documentoDetails") != null ? (Hashtable)view.getOutputAttribute("documentoDetails") : new Hashtable();
    String tipoDocumento = documentoDetails.get("tipoDocumento") != null ? (String)documentoDetails.get("tipoDocumento") : "";
    String numeroDocumento = documentoDetails.get("numeroDocumento") != null ? (String)documentoDetails.get("numeroDocumento") : "";
    String rilasciatoDa = documentoDetails.get("rilasciatoDa") != null ? (String)documentoDetails.get("rilasciatoDa") : "";
    String rilasciatoLuogo = documentoDetails.get("rilasciatoLuogo") != null ? (String)documentoDetails.get("rilasciatoLuogo") : "";
    String rilasciatoDate = documentoDetails.get("rilasciatoDate") != null ? (String)documentoDetails.get("rilasciatoDate") : "";
    String rilasciatoMonth = documentoDetails.get("rilasciatoMonth") != null ? (String)documentoDetails.get("rilasciatoMonth") : "";
    String rilasciatoYear = documentoDetails.get("rilasciatoYear") != null ? (String)documentoDetails.get("rilasciatoYear") : "";
    String scadenzaDate = documentoDetails.get("scadenzaDate") != null ? (String)documentoDetails.get("scadenzaDate") : "";
    String scadenzaMonth = documentoDetails.get("scadenzaMonth") != null ? (String)documentoDetails.get("scadenzaMonth") : "";
    String scadenzaYear = documentoDetails.get("scadenzaYear") != null ? (String)documentoDetails.get("scadenzaYear") : "";
    
    String rilasciatoLuogoNazione = documentoDetails.get("nazione") != null ? (String)documentoDetails.get("nazione") : "";
    String rilasciatoLuogoCitta = documentoDetails.get("citta") != null ? (String)documentoDetails.get("citta") : "";
    String rilasciatoLuogoProvincia = documentoDetails.get("strProvincia") != null ? (String)documentoDetails.get("strProvincia") : "";
    String cncf = documentoDetails.get("cncf") != null ? (String)documentoDetails.get("cncf") : "";
    Collection<Citta> collMultipleCitta = documentoDetails.get("cittaCollection") != null ? (Collection<Citta>)documentoDetails.get("cittaCollection") : null;
    String tipoLuogoEmissione = documentoDetails.get("tipoLuogoEmissione") != null ? (String)documentoDetails.get("tipoLuogoEmissione") : "";
    String isCittaDisable = "ITALIA".equals(rilasciatoLuogoNazione) || "ITALIA".equals(tipoLuogoEmissione) ? "":"disabled";
    String isProvinciaDisable = (collMultipleCitta != null && collMultipleCitta.size()> 0 && (!"".equals(rilasciatoLuogoProvincia) || collMultipleCitta.size() > 1 ) ) ? "":"hidden";
    
    Collection documentoCollection = (Collection)view.getOutputAttribute(ICensimentoPFConstants.DOCUMENTI_PF_VIEW_SESSION);
	String frimagraf =   (String)attributiDetails.get("frimagraf") ;
	String frimadata =  (String)attributiDetails.get("frimadata")  ;
	boolean isSessoReadOnly = attributiDetails.get("SESSO_READONLY") != null ? true : false ;
	boolean isCodiceFiscaliReadOnly = datiFiscaliDetails.get("CODICEFISCALI_READONLY") != null ? true : false ;
	String parpr = (String)attributiDetails.get("parpr") ;
	String atrpr = (String)attributiDetails.get("atrpr") ;
	final String A97_3bar46_link =(String)request.getAttribute("A97_3bar46_link");
	final String A97_6bar46_link=(String)request.getAttribute("A97_6bar46_link");
	String apivacausale = (String)view.getOutputAttribute("apivacausale");
	String apivadescrip =  (String)view.getOutputAttribute("apivadescrip");
	String sbj = attributiDetails.get("sbj")!= null? (String)attributiDetails.get("sbj"):"No";
	String apicale = attributiDetails.get("apicale")!= null? (String)attributiDetails.get("apicale"):"No";
	String isalboProfessione = (String) view.getOutputAttribute("alboProfessione");
	String isDisable ="TRUE".equalsIgnoreCase(isalboProfessione) ? "disabled" : "";
	ClassificazioneView classificazioneViewOfSettComm = null;
    String isDataScadenza = (String) view.getOutputAttribute("isDataScadenza");
    String isDisableScadenza="TRUE".equalsIgnoreCase(isDataScadenza) && !"".equals(scadenzaDate)&& !"".equals(scadenzaMonth) && !"".equals(scadenzaYear)? "disabled" : "";

	//Regime
		boolean regimeDeiMinimi = "on".equals(datiFiscaliDetails.get("regimeDeiMinimi")) ? true : false;
		String regimeDataAttivazioneDate = datiFiscaliDetails.get("regimeDataAttivazioneDate") != null ? (String)datiFiscaliDetails.get("regimeDataAttivazioneDate") : "";
		String regimeDataAttivazioneMonth = datiFiscaliDetails.get("regimeDataAttivazioneMonth") != null ? (String)datiFiscaliDetails.get("regimeDataAttivazioneMonth") : "";
		String regimeDataAttivazioneYear = datiFiscaliDetails.get("regimeDataAttivazioneYear") != null ? (String)datiFiscaliDetails.get("regimeDataAttivazioneYear") : "";
		String regimeDataRevocaDate = datiFiscaliDetails.get("regimeDataRevocaDate") != null ? (String)datiFiscaliDetails.get("regimeDataRevocaDate") : "";
		String regimeDataRevocaMonth = datiFiscaliDetails.get("regimeDataRevocaMonth") != null ? (String)datiFiscaliDetails.get("regimeDataRevocaMonth") : "";
		String regimeDataRevocaYear = datiFiscaliDetails.get("regimeDataRevocaYear") != null ? (String)datiFiscaliDetails.get("regimeDataRevocaYear") : "";
		String regimeDataScadenza = datiFiscaliDetails.get("regimeDataScadenza") != null ? (String)datiFiscaliDetails.get("regimeDataScadenza") : "";
		boolean isRegimeExists = view.getOutputAttribute("RegimeExists") != null && "true".equals((String)view.getOutputAttribute("RegimeExists")) ?  true : false;
		boolean isRegimeDataRevocaExists = view.getOutputAttribute("RegimeDataRevocaExists") != null && "true".equals((String)view.getOutputAttribute("RegimeDataRevocaExists")) ?  true : false;
		final String regime_Attivazione_Link=(String)request.getAttribute("Regime_Attivazione_Link");
		final String regime_Revoca_Link=(String)request.getAttribute("Regime_Revoca_Link");
		//Modalita
		final String modalita = new StringHandler().checkisNotEmpty(attributiDetails.get("modalita")) ? (String)attributiDetails.get("modalita") : "";
		Collection modalitaCollection = CensBean.getAllModalita();
		
		final String w9NoReasonCertificate = new StringHandler().checkisNotEmpty(datiFiscaliDetails.get("w9NoReasonCertificate")) ? (String)datiFiscaliDetails.get("w9NoReasonCertificate") : "";

		String isUsOriginDocumenti = "N";
		if(documentoCollection != null && documentoCollection.size() > 0){
			final Iterator iterator = documentoCollection.iterator();
			DocumentoPFView documentoView = null;
			for ( int i=0; i< documentoCollection.size(); i++ ) {
				documentoView = (DocumentoPFView)iterator.next();
				if(documentoView.getTipoDocumento() != null && "Green card".equals(documentoView.getTipoDocumento().getCausale())){
					isUsOriginDocumenti = "Y";
					break;
				}else if("STATI UNITI".equals(documentoView.getLuogoEmissione())) {
					isUsOriginDocumenti = "Y";
					break;
				}
			}
		}
		String residenzaFiscale2 = datiFiscaliDetails.get("residenzaFiscale2") != null ? (String)datiFiscaliDetails.get("residenzaFiscale2") : "";
		String residenzaFiscale3 = datiFiscaliDetails.get("residenzaFiscale3") != null ? (String)datiFiscaliDetails.get("residenzaFiscale3") : "";
		String codiceFiscaleEstero2 = datiFiscaliDetails.get("codiceFiscaleEstero2") != null ? (String)datiFiscaliDetails.get("codiceFiscaleEstero2") : "";
		String codiceFiscaleEstero3 = datiFiscaliDetails.get("codiceFiscaleEstero3") != null ? (String)datiFiscaliDetails.get("codiceFiscaleEstero3") : "";
		String altreResidenze = (!"".equals(residenzaFiscale2)||!"".equals(residenzaFiscale3)||!"".equals(codiceFiscaleEstero2)||!"".equals(codiceFiscaleEstero3)) ? "true" : "false";
		
%>
  <link rel="stylesheet" href="/css/Anagrafe/jquery-ui.css" />
  <script type="text/javascript" src="/script/Anagrafe/jquery-1.9.1.js"></script>
  <script type="text/javascript" src="/script/Anagrafe/jquery-ui.js"></script>
  <script type="text/javascript" src="/script/Anagrafe/jquery-combo.js"></script>
  


<script language="JavaScript">
	function populateTAE() {
		<sm:includeIfEventAllowed eventName="populateTAE" >
	               document.AttributiFiscaliDocumenti.action = "<sm:getEventMainURL/>";
	               document.AttributiFiscaliDocumenti.submit() ;
		</sm:includeIfEventAllowed>
	}
	function PopulateSettComm() {
		<sm:includeIfEventAllowed eventName="PopulateSettComm" >
	               document.AttributiFiscaliDocumenti.action = "<sm:getEventMainURL/>";
	               document.AttributiFiscaliDocumenti.submit() ;
		</sm:includeIfEventAllowed>
	}
	function PopulateExecuter() {
		<sm:includeIfEventAllowed eventName="PopulateExecuter" >
	               document.AttributiFiscaliDocumenti.action = "<sm:getEventMainURL/>";
	               document.AttributiFiscaliDocumenti.submit() ;
		</sm:includeIfEventAllowed>
	}
	
	function compareOldAndNewTAEVal(newTae){
		var oldTae = "<%=taeVal%>";
		var settComm = $("#setcommOld").val();
		if((newTae != oldTae) && newTae != "Digita o seleziona l'attività del cliente"){
			return true;
		}
		if((newTae != oldTae) && newTae == "Digita o seleziona l'attività del cliente"){
			$("#settCommLabel").hide();
		}else{
			$("#settCommLabel").show();
		}
		if( newTae == "Digita o seleziona l'attività del cliente" ){
			$("#setcomm").val('');
		}else{
			$("#setcomm").val(settComm);
		}
		
	}

	$(function() {
	    $( document ).tooltip();
	});
	
	
	
	$(document).ready(function(){
		var altreResidenze = '<%=altreResidenze%>';
		var resiFiscale2 = '<%=residenzaFiscale2%>';
		var resiFiscale3 = '<%=residenzaFiscale3%>';
		var cdEst2 = '<%=codiceFiscaleEstero2%>';
		var cdEst3 = '<%=codiceFiscaleEstero3 %>';
		if(altreResidenze=="false") {
			$('tr.altreResiFisSection').hide();
		}
		$("input:radio[name=altreResidenze]").click(function() {
		var selVal = $(this).val();
			if(selVal == 'Y' ) {
				var rf2SelVal = $("#residenzaFiscale2").val(); 
				if(resiFiscale2 != '' && resiFiscale2 != '--Select--' &&  rf2SelVal != resiFiscale2){
					$('#residenzaFiscale2').val(resiFiscale2);
				}		
				var rf3SelVal = $("#residenzaFiscale3").val(); 
				if(resiFiscale3 != '' && resiFiscale3 != '--Select--' && rf3SelVal != resiFiscale3){
					$('#residenzaFiscale3').val(resiFiscale3);
				}	
				if(cdEst2 != '') {
					$('#codiceFiscaleEstero2').val(cdEst2);
				}
				if(cdEst3 != '') {
					$('#codiceFiscaleEstero3').val(cdEst3);
				}				
				$('tr.altreResiFisSection').show();
			} else {
				$('#residenzaFiscale2').val('--Select--');
				$('#codiceFiscaleEstero2').val('');
				$('#residenzaFiscale3').val('--Select--');
				$('#codiceFiscaleEstero3').val('');
				$('tr.altreResiFisSection').hide();	
			}
	});

		 $('#identification').change(function(){
			 var identVal = $(this).val(); 
			 if(identVal == 'Si'){
				$("#ident").val(identVal);
			 }
		});



			
	});

			
  function disableAllButton(){
	for(i=0; i<document.AttributiFiscaliDocumenti.elements.length; i++) {
		if(document.AttributiFiscaliDocumenti.elements[i].type=="button" ||
			document.AttributiFiscaliDocumenti.elements[i].type=="submit") {
		 document.AttributiFiscaliDocumenti.elements[i].disabled=true;
		}
	}
  }

  function submitForm(){
	var isFormSubmiitedObj =  document.AttributiFiscaliDocumenti.isFormSubmiited;
  	 if(isFormSubmiitedObj.value != 'true'){
          <sm:includeIfEventAllowed eventName="Conferma" >
             document.AttributiFiscaliDocumenti.action = "<sm:getEventMainURL/>";
              isFormSubmiitedObj.value ='true';
              document.AttributiFiscaliDocumenti.submit() ;
          </sm:includeIfEventAllowed>
           return true;
     } else {
	 	return false;
  	 }
  }

  function submitMeAfterClickingImage( checkString , code ) {
	  var isFormSubmiitedObj =  document.AttributiFiscaliDocumenti.isFormSubmiited;
      if( checkString == "viewDetails" ) {
        if(isFormSubmiitedObj.value != 'true') {
               <sm:includeIfEventAllowed eventName="viewDetails" >
	        	       document.AttributiFiscaliDocumenti.action = "<sm:getEventMainURL/>&isscode="+code;
  	               isFormSubmiitedObj.value ='true';
      	           document.AttributiFiscaliDocumenti.submit() ;
                </sm:includeIfEventAllowed>
        }
      }else if( checkString == "UploadFiles" ) {
    	  if(isFormSubmiitedObj.value != 'true') {
    		  <sm:includeIfEventAllowed eventName="UploadFiles">
    		  	document.AttributiFiscaliDocumenti.action = "<sm:getEventMainURL/>&IdScansione="+code;
    		  	isFormSubmiitedObj.value ='true';
    	        document.AttributiFiscaliDocumenti.submit() ;
    		  </sm:includeIfEventAllowed>
    	  }
      }
  }

    function submitMe( checkString ) {
        var isFormSubmiitedObj =  document.AttributiFiscaliDocumenti.isFormSubmiited;
        if( checkString == "DocumentiAggiungi" ) {
          if(isFormSubmiitedObj.value != 'true') {
                 <sm:includeIfEventAllowed eventName="DocumentiAggiungi" >
  	        	       document.AttributiFiscaliDocumenti.action = "<sm:getEventMainURL/>";
    	               isFormSubmiitedObj.value ='true';
        	           document.AttributiFiscaliDocumenti.submit() ;
                  </sm:includeIfEventAllowed>
          }
        } else if(checkString == "DocumentiModifica") {
           if(isFormSubmiitedObj.value != 'true'){
                 <sm:includeIfEventAllowed eventName="DocumentiModifica" >
  	        	       document.AttributiFiscaliDocumenti.action = "<sm:getEventMainURL/>";
    	               isFormSubmiitedObj.value ='true';
        	           document.AttributiFiscaliDocumenti.submit() ;
                  </sm:includeIfEventAllowed>
           }
        } else if(checkString == "DocumentiElimina") {
           if(isFormSubmiitedObj.value != 'true'){
                 <sm:includeIfEventAllowed eventName="DocumentiElimina" >
  	        	       document.AttributiFiscaliDocumenti.action = "<sm:getEventMainURL/>";
    	               isFormSubmiitedObj.value ='true';
        	           document.AttributiFiscaliDocumenti.submit() ;
                  </sm:includeIfEventAllowed>
           }
        } else if(checkString == "AFDIndietro") {
           if(isFormSubmiitedObj.value != 'true'){
                 <sm:includeIfEventAllowed eventName="AFDIndietro" >
  	        	       document.AttributiFiscaliDocumenti.action = "<sm:getEventMainURL/>";
    	               isFormSubmiitedObj.value ='true';
        	           document.AttributiFiscaliDocumenti.submit() ;
                  </sm:includeIfEventAllowed>
           }
        } else if(checkString == "AFDAnnulla") {
           if(isFormSubmiitedObj.value != 'true'){
                 <sm:includeIfEventAllowed eventName="AFDAnnulla" >
  	        	       document.AttributiFiscaliDocumenti.action = "<sm:getEventMainURL/>";
    	               isFormSubmiitedObj.value ='true';
        	           document.AttributiFiscaliDocumenti.submit() ;
                  </sm:includeIfEventAllowed>
           }
        } else if(checkString == "Annulla") {
          if(isFormSubmiitedObj.value != 'true'){
                 <sm:includeIfEventAllowed eventName="Annulla" >
  	        	       document.AttributiFiscaliDocumenti.action = "<sm:getEventMainURL/>";
    	               isFormSubmiitedObj.value ='true';
        	           document.AttributiFiscaliDocumenti.submit() ;
                  </sm:includeIfEventAllowed>
          }
        } else if(checkString == "RicercaAttivita") {
          if(isFormSubmiitedObj.value != 'true'){
                 <sm:includeIfEventAllowed eventName="RicercaAttivita" >
  	        	       document.AttributiFiscaliDocumenti.action = "<sm:getEventMainURL/>";
    	               isFormSubmiitedObj.value ='true';
        	           document.AttributiFiscaliDocumenti.submit() ;
                  </sm:includeIfEventAllowed>
          }
        } else if(checkString == "DocDataDiScandenza") {
          if(isFormSubmiitedObj.value != 'true'){
                 <sm:includeIfEventAllowed eventName="DocDataDiScandenza" >
  	        	       document.AttributiFiscaliDocumenti.action = "<sm:getEventMainURL/>";
    	               isFormSubmiitedObj.value ='true';
        	           document.AttributiFiscaliDocumenti.submit() ;
                  </sm:includeIfEventAllowed>
          }
        } else if(checkString == "AcquisisciW9") {
          if(isFormSubmiitedObj.value != 'true'){
                 <sm:includeIfEventAllowed eventName="AcquisisciW9" >
  	        	       document.AttributiFiscaliDocumenti.action = "<sm:getEventMainURL/>";
    	               isFormSubmiitedObj.value ='true';
        	           document.AttributiFiscaliDocumenti.submit() ;
                  </sm:includeIfEventAllowed>
          }
        } else if(checkString == "AcquisisciW8BEN") {
         if(isFormSubmiitedObj.value != 'true'){
                 <sm:includeIfEventAllowed eventName="AcquisisciW8BEN" >
  	        	       document.AttributiFiscaliDocumenti.action = "<sm:getEventMainURL/>";
    	               isFormSubmiitedObj.value ='true';
        	           document.AttributiFiscaliDocumenti.submit() ;
                  </sm:includeIfEventAllowed>
         }
        } else if(checkString == "DocRilasciatoDa") {
          if(isFormSubmiitedObj.value != 'true'){
				// old value is resetted by empty
           		document.AttributiFiscaliDocumenti.rilasciatoDa.value ="";
           		document.AttributiFiscaliDocumenti.rilasciatoLuogoNazione.value = "Select";
           		document.AttributiFiscaliDocumenti.rilasciatoLuogoCitta.value = "";
                 <sm:includeIfEventAllowed eventName="DocRilasciatoDa" >
  	        	       document.AttributiFiscaliDocumenti.action = "<sm:getEventMainURL/>";
    	               isFormSubmiitedObj.value ='true';
        	           document.AttributiFiscaliDocumenti.submit() ;
                  </sm:includeIfEventAllowed>
          }
        } else if(checkString == "GeograficaLuogoEmissione") {
          if(isFormSubmiitedObj.value != 'true'){
           		//document.AttributiFiscaliDocumenti.rilasciatoLuogoCitta.value ="";
                 <sm:includeIfEventAllowed eventName="GeograficaLuogoEmissione" >
                 document.AttributiFiscaliDocumenti.elements["GEOGRAFICA_RICERCA_FOR"].value=checkString;
  	        	       document.AttributiFiscaliDocumenti.action = "<sm:getEventMainURL/>";
    	               isFormSubmiitedObj.value ='true';
        	           document.AttributiFiscaliDocumenti.submit() ;
                  </sm:includeIfEventAllowed>
          }
        } else if(checkString == "CittaDisable") {
        	var luogoNazione = document.AttributiFiscaliDocumenti.rilasciatoLuogoNazione.value;
        	var luogoNazioneName =null;
        	if(luogoNazione != "Select") {
        		luogoNazioneName = luogoNazione.split("^");
        	}
        	if((luogoNazioneName != null && luogoNazioneName[2] != "ITALIA") || luogoNazione == "Select") {
        		document.AttributiFiscaliDocumenti.rilasciatoLuogoCitta.value ="";
        		document.AttributiFiscaliDocumenti.rilasciatoLuogoCitta.disabled=true;
        		document.AttributiFiscaliDocumenti.cercaDoc.disabled=true;
        		if(document.AttributiFiscaliDocumenti.rilasciatoLuogoProvincia != null) {
        			document.AttributiFiscaliDocumenti.rilasciatoLuogoProvincia.value ="";
        		}
        		document.getElementById("rilasciatoLuogoProvinciaId").style.visibility="hidden";
        		document.getElementById("proviciaTag").style.visibility="hidden";
        	} else {
        		document.AttributiFiscaliDocumenti.rilasciatoLuogoCitta.value ="";
        		document.AttributiFiscaliDocumenti.rilasciatoLuogoCitta.disabled=false;
        		document.AttributiFiscaliDocumenti.cercaDoc.disabled=false;
        	}
        }
    }

    function trimS(strText) {
	 	return strText.replace(/^\s*|\s*$/g,"");
	}

	function submitScandenza( checkString ) {
		var rilasciatoDate = document.AttributiFiscaliDocumenti.rilasciatoDate.value;
		var rilasciatoMonth = document.AttributiFiscaliDocumenti.rilasciatoMonth.value;
		var rilasciatoYear = document.AttributiFiscaliDocumenti.rilasciatoYear.value;
		if ( rilasciatoDate != null && rilasciatoMonth != null && rilasciatoYear != null &&
			trimS(rilasciatoDate) != "" && trimS(rilasciatoMonth) != "" && trimS(rilasciatoYear) != ""  ) {
			submitMe(checkString);
		}
	}

    function doFocus() {
		<% if ( isAFDDatascanConvertion != null && "TRUE".equals(isAFDDatascanConvertion)  ) { %>
			document.forms["AttributiFiscaliDocumenti"].elements["scadenzaDate"].focus();
		<% }else if ( isAFDRilasciatoDaConvertion != null && "TRUE".equals(isAFDRilasciatoDaConvertion)  ) { %>
			document.forms["AttributiFiscaliDocumenti"].elements["numeroDocumento"].focus();
		<% }else{%>
			document.forms["AttributiFiscaliDocumenti"].elements["sesso"].focus();
		<%}%>
	}

    function displayW9() {
        var isUsOriginDatiIndirzzo    = document.AttributiFiscaliDocumenti.isUsOriginDatiIndirzzo.value;
        var isUsOriginAll      = document.AttributiFiscaliDocumenti.isUsOriginAll.value;

        var acquisisciW9Obj    = document.AttributiFiscaliDocumenti.AcquisisciW9;
        var w9LebelObj         = document.getElementById("w9Lebel");
        var w8BenRowObj		   = document.getElementById("w8BenRow");
        var w8LebelObj         = document.getElementById("w8Lebel");
        var w9Obj              = document.AttributiFiscaliDocumenti.w9;
        var w8Obj              = document.AttributiFiscaliDocumenti.w8;
        var numeroSicurezzaSocialeObj = document.AttributiFiscaliDocumenti.numeroSicurezzaSociale ;
        var codiceFiscaleEsteroObj = document.AttributiFiscaliDocumenti.codiceFiscaleEstero;
        var cittadinanza  = document.AttributiFiscaliDocumenti.cittadinanza.value;
        var secondaCittadinanza = document.AttributiFiscaliDocumenti.secondaCittadinanza.value;
        var residenzaValutaria = document.AttributiFiscaliDocumenti.residenzaValutaria.value;
        var residenzaFiscale = document.AttributiFiscaliDocumenti.residenzaFiscale.value;
        var rf2= document.getElementById("residenzaFiscale2");
        var rf3 = document.getElementById("residenzaFiscale3");
        var residenzaFiscale2 = rf2.options[rf2.selectedIndex].text;
        var residenzaFiscale3 = rf3.options[rf3.selectedIndex].text;
        //var rilasciatoLuogoNazioneStr = document.AttributiFiscaliDocumenti.rilasciatoLuogoNazione.value;
        var isPageUsPerson = false;
        var cfelabelOBj                = document.getElementById("cfelabel");
        var  isW9CertAllowed          = '<%= isW9CertAllowed %>';
        var isUsOriginDocumenti = '<%=isUsOriginDocumenti%>';
		var isUsOriginCollegate = document.AttributiFiscaliDocumenti.isUsCollegate.value;
		
         if ( codiceFiscaleEsteroObj != null && acquisisciW9Obj != null ) {

       		if ( (isUsOriginDatiIndirzzo == "Y" || isUsOriginCollegate == "Y") && isW9CertAllowed == 'true'  ) {
       			// To decide will display button or no ""  Dispaly "none"  No Display
            	 acquisisciW9Obj.style.display = "";
             	 codiceFiscaleEsteroObj.style.display = "none" ;
             	 codiceFiscaleEsteroObj.value='<%=codiceFiscaleEstero%>'
        	} else {
                
		        var cittadinanzaName =null;
		        var secondaCittadinanzaName = null;
		        var residenzaValutariaName = null;
		        var residenzaFiscaleName = null;
		          if ( cittadinanza != "--Select--" ) {
				       cittadinanzaName  =  cittadinanza.split("^");
			      }
				  if ( secondaCittadinanza != "--Select--" ) {
				    secondaCittadinanzaName  =  secondaCittadinanza.split("^");
			      }
			      if ( residenzaValutaria != "--Select--" ) {
				     residenzaValutariaName  =  residenzaValutaria.split("^");
			      }
			      if ( residenzaFiscale != "--Select--" ) {
				     residenzaFiscaleName  =  residenzaFiscale.split("^");
			      }

         		  if ( cittadinanzaName != null &&  cittadinanzaName[1] == "STATI UNITI" ) {
          	         isPageUsPerson  = true;
      	          }
          		  if ( secondaCittadinanzaName != null &&  secondaCittadinanzaName[1] == "STATI UNITI" ) {
          	         isPageUsPerson  = true;
      	          }
      	   		  if ( residenzaValutariaName != null &&  residenzaValutariaName[1] == "STATI UNITI" ) {
          	          isPageUsPerson  = true;
      	          }
      	   		  if ( residenzaFiscaleName != null &&  residenzaFiscaleName[1] =="STATI UNITI" ) {
          	          isPageUsPerson  = true;
      	          } 
      	   		  if ( residenzaFiscale2 != null &&  residenzaFiscale2 =="STATI UNITI" ) {
        	          isPageUsPerson  = true;
    	          }
      	   	     	if ( residenzaFiscale3 != null &&  residenzaFiscale3 =="STATI UNITI" ) {
    	          isPageUsPerson  = true;
	              }
 	            	if(isUsOriginDocumenti != null && isUsOriginDocumenti == "Y"){
      	        		isPageUsPerson  = true;
      	          } if (isUsOriginCollegate != null && isUsOriginCollegate == "Y") {
	      	        	isPageUsPerson  = true;
      	          }

      	       
		       	  if ( isPageUsPerson && isW9CertAllowed == 'true' ) {
               		acquisisciW9Obj.style.display = "";
	           		document.AttributiFiscaliDocumenti.isUsOriginAll.value = "Y";
	           		document.AttributiFiscaliDocumenti.w9NoReasonCertificate.value = '<%=w9NoReasonCertificate%>';
	           		codiceFiscaleEsteroObj.style.display = "none" ;
	           		codiceFiscaleEsteroObj.value='<%=codiceFiscaleEstero%>'
					cfelabelOBj.style.display = "";
              		if ( w9Obj != null ) {
              		     w9Obj.value="on";
              		}
		       	  } else {
	          		acquisisciW9Obj.style.display = "none";
              		document.AttributiFiscaliDocumenti.isUsOriginAll.value = "N";
              		document.AttributiFiscaliDocumenti.w9NoReasonCertificate.value = "";
              		codiceFiscaleEsteroObj.style.display = "" ;
			    	cfelabelOBj.style.display="none";
              		if ( w9LebelObj != null ) {
              		 // Only To change Label
              		 w9LebelObj.innerHTML = "No";
              		}
             		if ( w9Obj != null ) {
              		     w9Obj.value = "off";
              		 }
              		 numeroSicurezzaSocialeObj.value = "";
		       	 }
			}
    	 }

    	 if ( isUsOriginDatiIndirzzo == "Y" || isPageUsPerson ) {
	 		 if(w8BenRowObj != null) {
			    w8BenRowObj.style.display = "none";
			 }
	 		if (isPageUsPerson) {
	 		  if (w8Obj != null) {
	 		  	w8Obj.value = "off";
	 		  }
	  		  if (w8LebelObj != null){
	 		    w8LebelObj.innerHTML='No';
	 		  }
	 		}
	     } else {
			 if(w8BenRowObj != null) {
			    w8BenRowObj.style.display = "";
			 }
	     }
    }

	function displayW8(){
		 var acquisisciW8Obj           = document.AttributiFiscaliDocumenti.AcquisisciW8BEN;
		 var residenzaValutaria        = document.AttributiFiscaliDocumenti.residenzaValutaria.value;
         var residenzaFiscale          = document.AttributiFiscaliDocumenti.residenzaFiscale.value;
         var isPageUsPerson 	       = false;

         var isUsOriginDatiIndirzzo    = document.AttributiFiscaliDocumenti.isUsOriginDatiIndirzzo.value;
         var isUsOriginAll      = document.AttributiFiscaliDocumenti.isUsOriginAll.value;

         var residenzaValutariaName = null;
		 var residenzaFiscaleName = null;
         var cittadinanza  = document.AttributiFiscaliDocumenti.cittadinanza.value;
         var secondaCittadinanza = document.AttributiFiscaliDocumenti.secondaCittadinanza.value;
         var residenzaValutaria = document.AttributiFiscaliDocumenti.residenzaValutaria.value;
         var residenzaFiscale = document.AttributiFiscaliDocumenti.residenzaFiscale.value;
         var isUsOriginDocumenti = '<%=isUsOriginDocumenti%>';
 		 var isUsOriginCollegate = document.AttributiFiscaliDocumenti.isUsCollegate.value;
         /* var rilasciatoLuogoNazioneStr = document.AttributiFiscaliDocumenti.rilasciatoLuogoNazione.value;
         
         var rilasciatoLuogoNazione = null;
         if(rilasciatoLuogoNazioneStr != "Select") {
        	 rilasciatoLuogoNazione = rilasciatoLuogoNazioneStr.split("^");
         } */


	     var cittadinanzaName =null;
	     var secondaCittadinanzaName = null;
	     var residenzaValutariaName = null;
	     var residenzaFiscaleName = null;
	     if ( cittadinanza != "--Select--" ) {
		   cittadinanzaName  =  cittadinanza.split("^");
		 }
		 if ( secondaCittadinanza != "--Select--" ) {
		    secondaCittadinanzaName  =  secondaCittadinanza.split("^");
	     }
	     if ( residenzaValutaria != "--Select--" ) {
		     residenzaValutariaName  =  residenzaValutaria.split("^");
	     }
	     if ( residenzaFiscale != "--Select--" ) {
		     residenzaFiscaleName  =  residenzaFiscale.split("^");
		 }
  		 if ( cittadinanzaName != null &&  cittadinanzaName[1] == "STATI UNITI" ) {
   	        isPageUsPerson  = true;
         }
   		 if ( secondaCittadinanzaName != null &&  secondaCittadinanzaName[1] == "STATI UNITI" ) {
   	        isPageUsPerson  = true;
         }
   		 if ( residenzaValutariaName != null &&  residenzaValutariaName[1] == "STATI UNITI" ) {
   	       isPageUsPerson  = true;
         }
   		 if ( residenzaFiscaleName != null &&  residenzaFiscaleName[1] =="STATI UNITI" ) {
   	       isPageUsPerson  = true;
         }
   		 if(isUsOriginDocumenti != null && isUsOriginDocumenti == "Y"){
      		isPageUsPerson  = true;
         } if (isUsOriginCollegate != null && isUsOriginCollegate == "Y") {
      	 	isPageUsPerson  = true;
         }
         // for button w8
         if (acquisisciW8Obj != null) {
        	 if( !(isUsOriginDatiIndirzzo == 'Y' || isUsOriginAll == 'Y' || isPageUsPerson )) {
        	 	acquisisciW8Obj.style.display = "";
        	 } else{
        	 	acquisisciW8Obj.style.display = "none";
        	 }
         }
	}
</script>
<style>
  label {
    display: inline-block;
    width: 9em;
  }
  </style>

<body onLoad="doFocus();">
<form method="post" action="<sm:getMainURL/>" name="AttributiFiscaliDocumenti"  >
<% if ( view.getOutputAttribute("CENSIMENTOPF_ISFORPL") != null ) { %>
	<table width="100%" border="1" cellspacing="0" cellpadding="0" bordercolor="003366">
		<tr>
			<td height="31">
			<jsp:include page="/H2O/CensimentoPF/CensimentoPF.IndicatoreStato.jsp"/>
			</td>
		</tr>
	</table>
	<br>
<% } %>
	<table width="100%">
		<tr>
			<td width="100%" class="testoContatti">Anagrafica - Censimento Persona Fisica
			</td>
		</tr>
	</table>
	<br>

<% if ( attributiErrorMessage != null || datiFiscaleErrorMessage != null || documentoErrorMessage != null ||
		errorMessage != null) { %>
	<table width="100%" border="1" cellspacing="0" cellpadding="5" bordercolor="#CCCCCC" align="center">
		<tr>
			<td class="titolotab" height="35" align="left">
			<img src="/img/h2o/triangolo.gif" width="25" height="22" hspace="10" align="absmiddle">Dati Non Completi
			</td>
		</tr>
	</table>
	<br>
<% }
  if ( errorMessage != null ) { %>
	<table width="100%" border="1" cellspacing="0" cellpadding="5" bordercolor="#CCCCCC" align="center">
		<tr>
			<td class="titolotab" height="35" align="left">
			<img src="/img/h2o/triangolo.gif" width="25" height="22" hspace="10" align="absmiddle"><%= errorMessage %>
			</td>
		</tr>
	</table>
	<br>
<% }
  if ( attributiErrorMessage != null )  { %>
	<table width="100%" border="1" cellspacing="0" cellpadding="5" bordercolor="#CCCCCC" align="center">
		<tr>
			<td class="titolotab" height="35" align="left">
			<img src="/img/h2o/triangolo.gif" width="25" height="22" hspace="10" align="absmiddle"><%= attributiErrorMessage %>
			</td>
		</tr>
	</table>
	<br>
<% } %>

<table class="topH2O" width="100%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
			<table width="100%" bgColor="white">
				<tr>
					<td colspan="2" class="titolotab"><b>Attributi</b></td>
				</tr>
				<tr>
					<td class="VertSxAlta" width="50%">* Sesso</td>
					<td class="VertDxAlta" width="50%">
						<select   name="sesso" class="testocombo" >
<%  if ( isSessoReadOnly ) { %>
							<option selected value= "<%= ((String)attributiDetails.get("sesso")).trim() +"^"+((String)attributiDetails.get("sessoDescrizione")).trim() %>"> <%= ((String)attributiDetails.get("sessoDescrizione")).trim() %>
<%  } else {  %>
							<option selected value= "--Select--">Seleziona
<%
	    Collection sessoCollection = CensBean.getSesso();
		if ( sessoCollection != null ) {
			Iterator iterator = sessoCollection.iterator();
			ClassificazioneView clView = null;
			int size = sessoCollection.size();
			for ( int i=0; i<size; i++ ) {
              clView = (ClassificazioneView)iterator.next();
              if ( clView.getId().toString().equals(sesso) ) {
%>
							<option selected value= "<%= clView.getId()+"^"+clView.getDescrizione() %>"><%= clView.getDescrizione() %>
<%			  } else { %>
							<option value= "<%= clView.getId()+"^"+clView.getDescrizione() %>"><%= clView.getDescrizione() %>
<%            }
			}
		}
	}
%>
					  </select>
					</td>
				</tr>

<%
	AnagrafeHelper helper = new AnagrafeHelper();
    if ( !((helper.checkForMotiv(motivCollection,"ANTCI") || helper.checkForMotiv(motivCollection, "POSTE")) &&
    	 ! helper.isExistsuperiorMotivThanAntci(motivCollection))) {
%>
				<tr>
					<td class="VertSxAlta">Titolo 1</td>
					<td class="VertDxAlta">
                    	<select name="titolo1" class="testocombo">
							<option selected value= "--Select--">Seleziona
<%  	Collection titolo1Collection = CensBean.getTitolo1();
		if ( titolo1Collection != null ) {
			Iterator iterator = titolo1Collection.iterator();
			ClassificazioneView clView = null;
			int size = titolo1Collection.size();
			for ( int i=0; i<size; i++ ) {
				clView = (ClassificazioneView)iterator.next();
				if ( clView.getId().toString().equals(titolo1) ) {
%>
					<option selected value= "<%= clView.getId() %>"><%= clView.getDescrizione() %>
<%				} else { %>
							<option value= "<%= clView.getId() %>"><%= clView.getDescrizione() %>
<%          	}
			}
		}
						%>
                    	</select>
					</td>
				</tr>
				<tr>
					<td class="VertSxAlta">Titolo 2</td>
					<td class="VertDxAlta">
                    	<select name="titolo2" class="testocombo">
							<option selected value= "--Select--">Seleziona
<%  	Collection titolo2Collection = CensBean.getTitolo2();
		if ( titolo2Collection != null ) {
			Iterator iterator = titolo2Collection.iterator();
			ClassificazioneView clView = null;
			int size = titolo2Collection.size();
			for ( int i=0; i<size; i++ ) {
				clView = (ClassificazioneView)iterator.next();
				if ( clView.getId().toString().equals(titolo2) ) {
%>
							<option selected value= "<%= clView.getId() %>"><%= clView.getDescrizione() %>
<%				} else { %>
							<option value= "<%= clView.getId() %>"><%= clView.getDescrizione() %>
<%          	}
			}
		}
%>
                    	</select>
                  	</td>
				</tr>
				<tr>
                	<td class="VertSxAlta">Titolo di Studio</td>
                  	<td class="VertDxAlta">
                    	<select name="titoloDiStudio" class="testocombo">
							<option selected value= "--Select--">Seleziona
<%
		Collection tdsCollection = CensBean.getTitoloDiStudio();
		if ( tdsCollection != null ) {
			Iterator iterator = tdsCollection.iterator();
			ClassificazioneView clView = null;
			int size = tdsCollection.size();
			for ( int i=0; i<size; i++ ) {
				clView = (ClassificazioneView)iterator.next();
				if ( clView.getId().toString().equals(titoloDiStudio) ) {
%>
							<option selected value= "<%= clView.getId() %>"><%= clView.getDescrizione() %>
<%				} else { %>
							<option value= "<%= clView.getId() %>"><%= clView.getDescrizione() %>
<%          	}
			}
		}
%>
                    	</select>
                  	</td>
				</tr>
				<tr>
					<td class="VertSxAlta">* Lingua</td>
					<td class="VertDxAlta">
						<select name="lingua" class="testocombo">
							<option selected value= "--Select--">Seleziona
<%
		Collection linguaCollection = CensBean.getLingua();
		if ( linguaCollection != null ) {
			Iterator iterator = linguaCollection.iterator();
			ClassificazioneView clView = null;
			int size = linguaCollection.size();
			for ( int i=0; i<size; i++ ) {
				clView = (ClassificazioneView)iterator.next();
				if ( clView.getId().toString().equals(lingua) ) {
%>
							<option selected value= "<%= clView.getId() %>"><%= clView.getDescrizione() %>
<%				} else { %>
							<option value= "<%= clView.getId() %>"><%= clView.getDescrizione() %>
<%          	}
	    	}
		}
%>
                    	</select>
					</td>
				</tr>
				<tr>
					<td class="VertSxAlta">* Professione</td>
					<td class="VertDxAlta">
						<select name="professione" onChange="populateTAE();" class="testocombo">
							<option selected value= "--Select--">Seleziona</option>
<%
		Collection profCollection = JspPageHelper.sortClassificazioneViewByDesc(CensBean.getProfessione());
		if ( profCollection != null ) {
			Iterator iterator = profCollection.iterator();
			ClassificazioneView clView = null;
			int size = profCollection.size();
			for ( int i=0; i<size; i++ ) {
				clView = (ClassificazioneView)iterator.next();
				if (!ICensimentoPFConstants.PROFESSIONE_NON_DISPONIBILE_PROF34.equals(clView.getCausale())) {
				if ( clView.getId().toString().equals(professione) ) {
%>
							<option selected value= "<%= clView.getId() %>"><%= clView.getDescrizione()%></option>
<%				} else { %>
							<option value= "<%= clView.getId() %>"><%= clView.getDescrizione() %></option>
<%          	 } 
				}
			}
		}
%>
                    	</select>
					</td>
				</tr>
				<tr>
					<td class="VertSxAlta">Settore Attività </td>
					<td class="VertDxAlta">
						<select name="settattivita" onChange="PopulateExecuter();" class="testocombo">
							<option selected value= "--Select--">Seleziona</option>
						<%if(professione !=null && !"--Select--".equals(professione)){
		final List<SettoreDiAttivita> attivitaList = CensBean.getSettoreDiAttivitaByProffessioneId(Long.valueOf(professione));
		if ( attivitaList != null && !attivitaList.isEmpty()) {
			for(SettoreDiAttivita  settoreAttivita:attivitaList){

				if( settoreAttivita!=null && attivita !=null && settoreAttivita.getSettoreAttivitaId().equals(attivita.getSettoreAttivitaId())){
%>
							<option selected  value= "<%=settoreAttivita.getSettoreAttivitaId()%>"><%=settoreAttivita.getSettoreAttivitaDescription()%>
							</option>
							<%} else { %>
							<option  value= "<%=settoreAttivita.getSettoreAttivitaId()%>"><%=settoreAttivita.getSettoreAttivitaDescription()%>
							</option>
							<%} %>

                    		<%}
			}
			}%>
                    	</select>&nbsp;&nbsp;<a href="#" title="Selezionare il settore per agevolare la scelta del Tipo di Attività Economica, oppure selezionare direttamente l'Attività Economica">?</a>
					</td>
	
				</tr>
				
				<tr>
					<td class="VertSxAlta">* Tipo di Attività Economica(T.A.E)</td>

					<td  class="VertDxAlta"  >
						<select name="tae"   id="tae"  class="testocombo"  style="width: 550px" >
							<option selected   value= "--Select--" >Digita o seleziona l'attività del cliente</option>
<%
		Collection<TAE> taeCollection =professione !=null && !"--Select--".equals(professione) ? (attivita!=null && !"--Select--".equals(attivita.getSettoreAttivitaId()) ?CensBean.getTAEBYSettoreDiAttivita(Long.valueOf(professione),Long.valueOf(attivita.getSettoreAttivitaId())):  CensBean.getTAE(Long.valueOf(professione))):null;
		if ( taeCollection != null) {
			for(TAE taeColl:taeCollection){
				if( tae!=null && taeColl.getTaeId().equals(tae.getTaeId())){
					classificazioneViewOfSettComm =  taeColl.getSettoreCommerciale() ;
%>
							<option selected  value= "<%=tae.getTaeId()%>"><%=taeColl.getTaeDesc()%>
							</option>
							<%} else { %>
							<option  value= "<%=taeColl.getTaeId()%>"><%=taeColl.getTaeDesc()%>
							</option>
							<%} %>

                    		<%}
			}
			%>
			</select>
					</td>
				</tr>
			
<%
if(classificazioneViewOfSettComm !=null ){
			final String settCommer = classificazioneViewOfSettComm.getCausale().concat("-").concat(classificazioneViewOfSettComm.getDescrizione());
			%>
<tr id="settCommLabel">	
		<td class="VertSxAlta" >Settore Commerciale</td>
		<td class="VertDxAlta" >
			  <%=settCommer %>   
			  <input  id="setcomm" type ="hidden" name="setcomm" value="<%=classificazioneViewOfSettComm.getId()%>">
			  <input  id="setcommOld" type ="hidden" name="setcommOld" value="<%=classificazioneViewOfSettComm.getId()%>">
		</td>
</tr>
		<% } %>
			<tr>
					<td class="VertSxAlta">Albo professionale</td>
					<td class="VertDxAlta">
						<select name="albo" class="testocombo" style="width: 550px" <%=isDisable%>>
							<option selected value= "--Select--" >Seleziona</option>
<%
		Collection<AlboProfessione> alboCollection = CensBean.getAlboProfessiones(Long.valueOf(ICensimentoPFConstants.Semplice));
		if ( alboCollection != null ) {
			for(AlboProfessione alboColl:alboCollection){
				if( albo!=null && alboColl.getAlboId().equals(albo.getAlboId())){
%>
							<option  selected value= "<%= albo.getAlboId()%>"><%=alboColl.getAlboDesc()%>
                     </option>
                     <%} else{ %>
                     <option   value= "<%= alboColl.getAlboId()%>"><%=alboColl.getAlboDesc()%></option>
                     <%} %>
			<%}
			}%>
				</select>
					</td>

				</tr>
			<tr>
			<td class="VertSxAlta" width="20%">Numero di iscrizione all' albo</td>
				  	<td class="VertDxAlta" width="80%" >

				  	<input type="text" name="numero" maxlength="50"  value="<%=numero%>"class="testocombo" size="18" <%=isDisable%>></td>
			</tr>
			<tr>
			<td class="VertSxAlta" width="20%">Ulteriori annotazioni</td>
				  	<td class="VertDxAlta" width="80%">
				  	<textarea rows="3" cols="25" name="ulteriori"  maxlength="200" <%=isDisable%>><%=ulteriori%></textarea></td>
			</tr>
			  <tr>
                	<td class="VertSxAlta" width="20%">Soggetto apicale</td>
                	<td class="VertDxAlta" width="80%">
                	<% if ( "true".equals(apicale) ) { %>

				  	<input type="radio" name="apicale" value="true" checked> S&igrave;
					<input type="radio" name="apicale" value="false" >No
					<% } else { %>
					<input type="radio" name="apicale" value="true" > S&igrave;
					<input type="radio" name="apicale" value="false" checked>No
					<%} %>
				  	</td>
                </tr>
				<tr>
					<td class="VertSxAlta">* Stato Civile</td>
					<td class="VertDxAlta">
                    	<select name="statoCivile" class="testocombo">
							<option selected value= "--Select--">Seleziona
<%
		Collection statoCivileCollection = CensBean.getStatoCivile();
		if ( statoCivileCollection != null ) {
			Iterator iterator = statoCivileCollection.iterator();
			ClassificazioneView clView = null;
			int size = statoCivileCollection.size();
			for ( int i=0; i<size; i++ ) {
				clView = (ClassificazioneView)iterator.next();
				if ( clView.getId().toString().equals(statoCivile) ) {
%>
							<option selected value= "<%= clView.getId() %>"><%= clView.getDescrizione() %>
<%				} else { %>
							<option value= "<%= clView.getId() %>"><%= clView.getDescrizione() %>
<%          	}
			}
		}
%>
                    	</select>
					</td>
				</tr>
				<tr>
					<td class="VertSxAlta">Regime Patrimoniale</td>
					<td class="VertDxAlta">
                    	<select name="regimePatrimoniale" class="testocombo">
							<option selected value= "--Select--">Seleziona
<%
		Collection regimePatrimonialeCollection = CensBean.getRegimePatrimoniale();
		if ( regimePatrimonialeCollection != null ) {
			Iterator iterator = regimePatrimonialeCollection.iterator();
			ClassificazioneView clView = null;
			int size = regimePatrimonialeCollection.size();
			for ( int i=0; i<size; i++ ) {
				clView = (ClassificazioneView)iterator.next();
				if ( clView.getId().toString().equals(regimePatrimoniale) ) {
%>
							<option selected value= "<%= clView.getId() %>"><%= clView.getDescrizione() %>
<%				} else { %>
							<option value= "<%= clView.getId() %>"><%= clView.getDescrizione() %>
<%          	}
			}
		}
%>
                    	</select>
					</td>
				</tr>
				<!--<tr>
					<td class="VertSxAlta" width="30%">Attività ISTAT dell'Azienda presso cui lavora il soggetto <font color="red">(solo se lavoratore dipendente)</font></td>
					<td class="VertDxAlta" width="61%">
    					<input type="text" name="attivita" value="" class="testocombo" size="40" readOnly>
					</td>
                	<TD class="VertDxAlta" align="center" width="9%">
                   		<input type="Button" name="Cerca" value="Cerca" onClick="disableAllButton();submitMe('RicercaAttivita')" style="cursor:hand" class="bottone">
                	</TD>
				</tr>


--><%} else {%>
                    <INPUT type="hidden" name="titolo1" value="--Select--">
                    <INPUT type="hidden" name="titolo2" value="--Select--">
                    <INPUT type="hidden" name="titoloDiStudio" value="--Select--">
                    <INPUT type="hidden" name="lingua" value="--Select--">
                    <INPUT type="hidden" name="professione" value="--Select--">
                    <INPUT type="hidden" name="statoCivile" value="--Select--">
                    <INPUT type="hidden" name="regimePatrimoniale" value="--Select--">
                    <INPUT type="hidden" name="attivita" value="">
 <% } %>
 <tr>
					<td class="VertSxAlta">* Cittadinanza</td>
					<td class="VertDxAlta">
                    	<select name="cittadinanza" class="testocombo" onchange="displayW9();displayW8()">
							<option selected value= "--Select--">Seleziona
<%
		Nazione italiaNazione = CensBean.getNazione("ITALIA");
		if ( italiaNazione != null ) {
%>
							<option value= "<%= italiaNazione.getNazioneId()+"^"+italiaNazione.getNome()+"^"+italiaNazione.getDocAggiuntivi() %>"><%= italiaNazione.getNome() %>
<%		}
		Collection naziones = CensBean.getNazione();
		if ( naziones != null ) {
			Iterator iterator = naziones.iterator();
			Nazione nazione = null;
			int size = naziones.size();
			for( int i=0; i<size; i++ ) {
				nazione = (Nazione)iterator.next();
				if ( nazione.getNazioneId().toString().equals(cittadinanza) ) {
%>
							<option selected value= "<%= nazione.getNazioneId()+"^"+nazione.getNome()+"^"+nazione.getDocAggiuntivi() %>"><%= nazione.getNome() %>
<%				} else { %>
							<option value= "<%= nazione.getNazioneId()+"^"+nazione.getNome()+"^"+nazione.getDocAggiuntivi() %>"><%= nazione.getNome() %>
<%          	}
			}
		}
%>
                    	</select>
					</td>
				</tr>
				<tr>
					<td class="VertSxAlta">Seconda Cittadinanza</td>
					<td class="VertDxAlta">
                    	<select name="secondaCittadinanza" class="testocombo" onchange="displayW9();displayW8()">
							<option selected value= "--Select--">Seleziona
<%		if ( italiaNazione != null ) { %>
							<option value= "<%= italiaNazione.getNazioneId()+"^"+italiaNazione.getNome()+"^"+italiaNazione.getDocAggiuntivi() %>"><%= italiaNazione.getNome() %>
<%		}
		if ( naziones != null ) {
			Iterator iterator = naziones.iterator();
			Nazione nazione = null;
			int size = naziones.size();
			for ( int i=0; i<size; i++ ) {
				nazione = (Nazione)iterator.next();
				if ( nazione.getNazioneId().toString().equals(secondaCittadinanza) ) {
%>
							<option selected value= "<%= nazione.getNazioneId()+"^"+nazione.getNome()+"^"+nazione.getDocAggiuntivi() %>"><%= nazione.getNome() %>
<%				} else { %>
							<option value= "<%= nazione.getNazioneId()+"^"+nazione.getNome()+"^"+nazione.getDocAggiuntivi() %>"><%= nazione.getNome() %>
<%          	}
			}
		}
%>
                    	</select>
					</td>
				</tr>
 <%  if ( !((helper.checkForMotiv(motivCollection,"ANTCI") || helper.checkForMotiv(motivCollection,"POSTE")) &&
    	 ! helper.isExistsuperiorMotivThanAntci(motivCollection))) {   %>
    	 	<tr>
					<td class="VertSxAlta" width="20%"><b>Autorizzato allo sconfino</b></td>
				  	<td class="VertDxAlta" width="80%">
<% 		if ( "true".equals(nosconf) ) { %>
						<input type="radio" name="nosconf" value="true" checked>S&igrave;
						<input type="radio" name="nosconf" value="false">No
						<input type="radio" name="nosconf" value="SottoOsservazione">Sotto Osservazione
<% 		} else if("false".equals(nosconf)) { %>
				  		<input type="radio" name="nosconf" value="true">S&igrave;
				  		<input type="radio" name="nosconf" value="false" checked>No
				  		<input type="radio" name="nosconf" value="SottoOsservazione">Sotto Osservazione
<% 		} else { %>
				  		<input type="radio" name="nosconf" value="true">S&igrave;
				  		<input type="radio" name="nosconf" value="false" >No
				  		<input type="radio" name="nosconf" value="SottoOsservazione" checked>Sotto Osservazione
<% 		} %>
				  	</td>
				</tr>
				<tr>
					<td class="VertSxAlta" width="20%">Parente promotore BPA</td>
				  	<td class="VertDxAlta" width="80%">
				  	<input type="radio" name="parpr" value="true" <%="true".equals(parpr) ? "checked" :""%> >S&igrave;
					<input type="radio" name="parpr" value="false" <%=!"true".equals(parpr) ? "checked" :""%>>No
				  	</td>
				</tr>
				<tr>
					<td class="VertSxAlta" width="20%">Promotore altre banche</td>
				  	<td class="VertDxAlta" width="80%">
				  	<input type="radio" name="atrpr" value="true" <%="true".equals(atrpr) ? "checked" :""%>>S&igrave;
					<input type="radio" name="atrpr" value="false" <%=!"true".equals(atrpr) ? "checked" :""%>>No
				  	</td>
				</tr>

<%  } else { %>
					<INPUT type="hidden" name="nosconf" value="true">
                    <INPUT type="hidden" name="parpr" value="false">
                    <INPUT type="hidden" name="atrpr" value="false">

                <% } %>

                <tr>
                	<td class="VertSxAlta" width="20%">Soggetto idoneo potenziale azionista BSH - BSE</td>
                	<td class="VertDxAlta" width="80%">
                	<% if ( "true".equals(sbj) ) { %>

				  	<input type="radio" name="sbj" value="true" checked> S&igrave;
					<input type="radio" name="sbj" value="false" >No
					<% } else { %>
					<input type="radio" name="sbj" value="true" > S&igrave;
					<input type="radio" name="sbj" value="false" checked>No
					<%} %>
				  	</td>
                </tr>
				<INPUT type="hidden" name="socioBSE" value="<%= attributiDetails.get("socioBSE")  != null ? attributiDetails.get("socioBSE") : "" %>">
            	<INPUT type="hidden" name="socioSHB" value="<%= attributiDetails.get("socioSHB")  != null ? attributiDetails.get("socioSHB") : "" %>">
		  	</table>
  		</td>
	</tr>
</table>
<br>

<% if ( datiFiscaleErrorMessage != null )  { %>
<table width="100%" border="1" cellspacing="0" cellpadding="5" bordercolor="#CCCCCC" align="center">
	<tr>
		<td class="titolotab" height="35" align="left">
		<img src="/img/h2o/triangolo.gif" width="25" height="22" hspace="10" align="absmiddle"><%= datiFiscaleErrorMessage %>
		</td>
	</tr>
</table>
<br>
<% } %>


<table class="topH2O" width="100%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
			<table width="100%" bgColor="white">
				<tr>
					<td colspan="5"  class="titolotab"><b>Dati Fiscali</b></td>
				</tr>
				<tr>
					<td class="VertSxAlta" width="50%">* Codice Fiscale  (OBBLIGATORIO anche per residenti estero)</td>
					<td class="VertDxAlta" width="50%">
<% if ( isCodiceFiscaliReadOnly ) { %>
						<input type="hidden" name="CODICEFISCALI_READONLY" value="true">
        				<input type="text" name="codiceFiscale" maxlength="16" value="<%= codiceFiscale %>" size="22" readonly  class="testocombo">
<%	} else {	%>
        				<input type="text" name="codiceFiscale" maxlength="16" value="<%= codiceFiscale %>" size="22" class="testocombo">
<%	}	%>
					</td>
                </tr>
<% if ( !((helper.checkForMotiv(motivCollection,"ANTCI") || helper.checkForMotiv(motivCollection,"POSTE")) &&
		!helper.isExistsuperiorMotivThanAntci(motivCollection))) {
%>
				<tr>
					<td class="VertSxAlta">Partita Iva</td>
					<td class="VertDxAlta">
						<input type="text" name="partitaIva" value="<%= partitaIva %>" maxlength="11" class="testocombo" size="22">
					</td>
				</tr>
				<tr>
					<td class="VertSxAlta">Applicazione IVA</td>
					<td class="VertDxAlta"><%=apivacausale != null && apivadescrip != null ?  apivacausale+"-"+apivadescrip: ""%></td>
				</tr>
				<%}else { %>
				  <input type="hidden" name="partitaIva" value="">
				<% } %>
				<% if ( !( helper.checkForMotiv(motivCollection,"POSTE") &&
		!helper.isExistsuperiorMotivThanAntci(motivCollection))) {
%>
<% if ( !((helper.checkForMotiv(motivCollection,"ANTCI") || helper.checkForMotiv(motivCollection,"POSTE")) &&
		!helper.isExistsuperiorMotivThanAntci(motivCollection))) {
%>
                <tr>
					<td class="VertSxAlta">Residenza Valutaria</td>
					<td class="VertDxAlta">
						<select name="residenzaValutaria" class="testocombo" onchange="displayW9();displayW8()">
							<option selected value= "--Select--">Seleziona
<%
		if ( nazioneCollection != null ) {
			Iterator iterator = nazioneCollection.iterator();
			Nazione nazione = null;
			int size = nazioneCollection.size();
			for ( int i=0; i<size; i++ ) {
				nazione = (Nazione)iterator.next();
				if ( nazione.getNome().equals(residenzaValutaria) ) {
%>
							<option selected value= "<%= nazione.getNazioneId()+"^"+nazione.getNome() %>"><%= nazione.getNome() %>
<%				} else { %>
							<option value= "<%= nazione.getNazioneId()+"^"+nazione.getNome() %>"><%= nazione.getNome() %>
<%          	}
			}
		}
%>
                    	</select>
					</td>
				</tr>
				
				<% } %>
                <tr>
					<td class="VertSxAlta">Residenza Fiscale </td>
					<td class="VertDxAlta">
						<select name="residenzaFiscale"  onchange="displayW9();displayW8()">
							<option selected value= "--Select--">Seleziona
<%
		if ( nazioneCollection != null ) {
				Iterator iterator = nazioneCollection.iterator();
				Nazione nazione = null;
				int size = nazioneCollection.size();
				for ( int i=0; i<size; i++ ) {
					nazione = (Nazione)iterator.next();
					if ( nazione.getNome().equals(residenzaFiscale) ) {
%>
								<option selected value= "<%= nazione.getNazioneId()+"^"+nazione.getNome() %>"><%= nazione.getNome() %>
<%					} else { %>
								<option value= "<%= nazione.getNazioneId()+"^"+nazione.getNome() %>"><%= nazione.getNome() %>
<%  	        	}
				}
		}
%>
						</select>
					</td>
				</tr>
				 <tr>
                  	<td  class="VertSxAlta">Codice Identificativo Fiscale Estero &nbsp;<a href="/Anagrafe/include/NazioneList.html" target="_blank">(elenco nazioni)</a>
                  	<br>E' richiesto per soggetti con Res. Fiscale all'Estero. E' utilizzato nella dichiarazione dei sostituti d'imposta.
                  	</td>
                  	<% if ( !((helper.checkForMotiv(motivCollection,"ANTCI")) &&
		!helper.isExistsuperiorMotivThanAntci(motivCollection))) {
%>
                  	<td  class="VertDxAlta">
                    	<label class="testocombo" id="cfelabel"
                    		style="display:<%= ( "Y".equals( isUsOriginDatiIndirzzo ) || "Y".equals( isUsOriginAll ) && isW9CertAllowed ) ? "" : "none"%>">
                  	    	<%= codiceFiscaleEstero %>
                  	    </label>
                    	<input type="text" name="codiceFiscaleEstero" value="<%= codiceFiscaleEstero %>" size="22" maxlength="20" class="testocombo"
                    		style="display:<%= ( "Y".equals( isUsOriginDatiIndirzzo ) || "Y".equals( isUsOriginAll ) && isW9CertAllowed ) ? "none" : ""%>" >
                    	<input type="hidden" name="numeroSicurezzaSociale" value="<%= numeroSicurezzaSociale %>" size="22" maxlength="20" class="testocombo">
					</td>
					<%} else { %>
					<td  class="VertDxAlta">
                     	<input type="text" name="codiceFiscaleEstero" value="<%= codiceFiscaleEstero %>" size="22" maxlength="20" class="testocombo">
					</td>
					<% } %>
                </tr>
                <%if(isAlterResidAllowed){ %>              
   			 <tr >
					<td class="VertSxAlta" width="20%"><b>Sono presenti altre residenze fiscali?</b></td>
				  	<td class="VertDxAlta" width="80%">
				  	<input type="radio" name="altreResidenze"  value="Y" <%="true".equals(altreResidenze) ? "checked" :""%> >S&igrave;
					<input type="radio" name="altreResidenze"  value="N" <%=!"true".equals(altreResidenze) ? "checked" :""%>>No
				  	</td>
				</tr>

        <tr class="altreResiFisSection">
					<td class="VertSxAlta" >Seconda Residenza Fiscale</td>
					<td class="VertDxAlta">
						<select name="residenzaFiscale2" id="residenzaFiscale2" onchange="displayW9();displayW8()">
							<option selected value= "--Select--">Seleziona
<%
		if ( nazioneCollection != null ) {
				for(Nazione nazione :nazioneCollection){
					if (!"ITALIA".equals(nazione.getNome())) {
					if ( nazione.getNazioneId().toString().equals(residenzaFiscale2) ) {
%>
								<option selected value= "<%= nazione.getNazioneId()%>"><%= nazione.getNome() %>
<%					} else { 
%>
								<option value= "<%= nazione.getNazioneId() %>"><%= nazione.getNome() %>
<%  	        	}
						}
				}
		}
%>
						</select>
					</td>
				</tr>
				 <tr class="altreResiFisSection">
                  	<td  class="VertSxAlta" >Secondo Codice Identificativo Fiscale Estero
                  	</td>
                  	<td  class="VertDxAlta">
                       <input type="text" name="codiceFiscaleEstero2" id="codiceFiscaleEstero2" value="<%= codiceFiscaleEstero2 %>" maxlength="20">
					</td>
                </tr>
				    <tr class="altreResiFisSection">
					<td class="VertSxAlta" id="RF3">Terza residenza fiscale</td>
					<td class="VertDxAlta">
						<select name="residenzaFiscale3"  id="residenzaFiscale3" onchange="displayW9();displayW8()">
							<option selected value= "--Select--">Seleziona
<%
		if ( nazioneCollection != null ) {
				for(Nazione nazione :nazioneCollection){
					if (!"ITALIA".equals(nazione.getNome())) {	
					if (nazione.getNazioneId().toString().equals(residenzaFiscale3) ) {
%>
								<option selected value= "<%= nazione.getNazioneId() %>"><%= nazione.getNome() %>
<%					} else { %>
								<option value= "<%= nazione.getNazioneId() %>"><%= nazione.getNome() %>
<%  	        	}
						}
				}
		}
%>
						</select>
					</td>
				</tr>
  <tr class="altreResiFisSection">
                  	<td  class="VertSxAlta" id="CF3">Terzo Codice Identificativo Fiscale Estero
                  	</td>
                  	<td  class="VertDxAlta">
                       <input type="text" name="codiceFiscaleEstero3" id="codiceFiscaleEstero3" value="<%= codiceFiscaleEstero3 %>" maxlength="20">
					</td>
                </tr>
 <%}else{ %> 
   					<input type="hidden" name="residenzaFiscale2" value="<%=residenzaFiscale2 %>">
                    <input type="hidden" name="residenzaFiscale3" value="<%=residenzaFiscale3 %>">
                    <input type="hidden" name="codiceFiscaleEstero3" value="<%=codiceFiscaleEstero3%>">
                    <input type="hidden" name="codiceFiscaleEstero2" value="<%=codiceFiscaleEstero2%>">
 <%} %> 
 
 <% if ( !((helper.checkForMotiv(motivCollection,"ANTCI") || helper.checkForMotiv(motivCollection,"POSTE")) &&
		!helper.isExistsuperiorMotivThanAntci(motivCollection))) {
%>
				<tr>
					<td class="VertSxAlta">* Certificato di Attestazione di Residenza  Valutaria in Stato Estero</td>
					<td class="VertDxAlta">
<% 	  if ( indicatoreRV)  {  %>
						<input type="checkbox" checked name="indicatoreRV" value="on">
<% 	  } else  {  %>
						<input type="checkbox" name="indicatoreRV">
<% 	  } %>
					</td>
				</tr>
			
				<tr>
					<td class="VertSxAlta">* <b>A97</b>
					<% if(A97_3bar46_link != null && A97_6bar46_link != null){%>
					Certificato di Attestazione di Residenza Fiscale in Stato diverso da quello Italiano (disponibile in Modulistica: mod. <a href="<%=A97_3bar46_link%>" target="_blank">3/46</a> per persone fisiche o mod. <a href="<%=A97_6bar46_link%>" target="_blank">6/46</a> per persone giuridiche)
					<%}else{ %>
					Certificato di Attestazione di Residenza Fiscale in Stato diverso da quello Italiano
					<%} %>
					</td>
					<td class="VertDxAlta">
<% 		if ( indicatoreA97 ) { %>
						<input type="checkbox" checked name="indicatoreA97" value="on">
<% 		} else { %>
						<input type="checkbox" name="indicatoreA97">
<% 		} %>
					</td>
				</tr>
                <tr>
					<td class="VertSxAlta"><b>A96</b> Modello di Autocertificazione per la non applicazione delle imposte nei confronti dei soggetti non residenti
					<a href="http://www.agenziaentrate.gov.it/wps/content/Nsilib/Nsi/Documentazione/Fiscalita+internazionale/White+list+e+Autocertificazione/Autocertificazione/" target="_blank">(http://www.agenziaentrate.gov.it/wps/content/.../Autocertificazione/)</a></td>
					<td  class="VertDxAlta">
<% 		if ( indicatoreA96 ) { %>
                    	<input type="checkbox" checked name="indicatoreA96" value="on">
<% 		} else { %>
                    	<input type="checkbox" name="indicatoreA96" >
<% 		} %>
					</td>
                </tr>
                
               
                      
	<tr>
      	<td  class="VertSxAlta"><b>Regime dei minimi</b></td>
      	<td  class="VertDxAlta">
						<input type="checkbox"  name="regimeDeiMinimi" value="on" <%=regimeDeiMinimi ? "checked" : ""%> <%=isRegimeExists ? "onclick='return false' onkeydown='return false' " : ""%> >
		</td>
			
    </tr>
    <tr>
      	<td class="VertSxAlta">Data attivazione (gg/mm/aaaa) - <%= regime_Attivazione_Link != null ? "<a href='"+regime_Attivazione_Link+"' target='_blank'>Modello autocertificazione adesione</a>" : "Modello autocertificazione adesione"%></td>
      	<td class="VertDxAlta">
        	<input type="text" name="regimeDataAttivazioneDate" maxlength="2" size="2" value ="<%= regimeDataAttivazioneDate %>" onBlur=" isDigit(this);" onKeyUp="changeFocusOffset (this, 2, 1)"  class="testocombo" <%=isRegimeExists ? "readonly='readonly'" : ""%>>&nbsp;/
        	<input type="text" name="regimeDataAttivazioneMonth" size="2" maxlength=2  value="<%= regimeDataAttivazioneMonth %>"  onBlur=" isDigit(this);" onKeyUp="changeFocusOffset (this, 2, 1)" class="testocombo" <%=isRegimeExists ? "readonly='readonly' " : ""%>>&nbsp;/
        	<input type="text" name="regimeDataAttivazioneYear" maxlength="4" size="4" value ="<%= regimeDataAttivazioneYear %>" onBlur=" isDigit(this);" onKeyUp="changeFocusOffset (this, 4, 0)" class="testocombo" <%=isRegimeExists ? "readonly='readonly'" : ""%>>
      	</td>
    </tr>
    <tr>
      	<td class="VertSxAlta">Data revoca (gg/mm/aaaa) - <%= regime_Revoca_Link != null ? "<a href='"+regime_Revoca_Link+"' target='_blank'>Modello autocertificazione revoca</a>" : "Modello autocertificazione revoca"%></td>
      	<td class="VertDxAlta">
        	<input type="text" name="regimeDataRevocaDate" maxlength="2" size="2" value ="<%= regimeDataRevocaDate %>" onBlur=" isDigit(this);" onKeyUp="changeFocusOffset (this, 2, 1)" class="testocombo" <%=isRegimeDataRevocaExists ? "readonly='readonly'" : ""%>>&nbsp;/
        	<input type="text" name="regimeDataRevocaMonth" size="2" maxlength=2  value="<%= regimeDataRevocaMonth %>"  onBlur=" isDigit(this);" onKeyUp="changeFocusOffset (this, 2, 1)" class="testocombo" <%=isRegimeDataRevocaExists ? "readonly='readonly'" : ""%>>&nbsp;/
        	<input type="text" name="regimeDataRevocaYear" maxlength="4" size="4" value ="<%= regimeDataRevocaYear %>" onBlur=" isDigit(this);" onKeyUp="changeFocusOffset (this, 4, 0)" class="testocombo" <%=isRegimeDataRevocaExists ? "readonly='readonly'" : ""%>>
      	</td>
    </tr>
    <tr>
      	<td class="VertSxAlta">Data scadenza  (gg/mm/aaaa)</td>
      	<td class="VertDxAlta">
			 <input type="hidden" name="regimeDataScadenza" value="<%=regimeDataScadenza%>">
			 <%=regimeDataScadenza%>
      	</td>
    </tr>
    <%} %>
<%  } else { %>
                    <input type="hidden" name="partitaIva" value="">
                    <input type="hidden" name="residenzaValutaria" value="--Select--">
                    <input type="hidden" name="residenzaFiscale" value="--Select--">
                    <input type="hidden" name="codiceFiscaleEstero" value="">
                    <input type="hidden" name="numeroSicurezzaSociale" value="">
<% } %>
             </table>
		 </td>
	</tr>
</table>
<br>
<% if(!((helper.checkForMotiv(motivCollection,"ANTCI") || helper.checkForMotiv(motivCollection,"POSTE")) && !helper.isExistsuperiorMotivThanAntci(motivCollection))) { %>
<input type="hidden" name="fatcaSoggettoUSA" id="fatcaSoggettoUSA" value="<%= fatcaSoggettoUSA %>" />
<input type="hidden" name="fatcaStatus" id="fatcaStatus" value="<%= fatcaStatus %>" />
<input type="hidden" name="presenzaDiIndizi" id="presenzaDiIndizi" value="<%= presenzaDiIndizi %>" />
<table class="topH2O" width="100%" cellpadding="1" cellspacing="0">
<tr><td>
<table width="100%" bgColor="white">
	<tr>
		<td colspan="3"  class="titolotab"><b>SOGGETTO USA</b></td>
	</tr>
	<sm:includeIfEventAllowed eventName="fatca_soggetto_usa" eventDescription="fatca_soggetto_usa">
	<tr>
		<td  class="VertSxAlta"><b>FATCA SOGGETTO USA</b></td>
		<td  class="VertDxAlta" colspan="2"><%= fatcaSoggettoUSA %></td>
	</tr>
	<tr>
		<td  class="VertSxAlta"><b>FATCA STATUS</b></td>
		<td  class="VertDxAlta" colspan="2"> <%= fatcaStatus %></td>
	</tr>
	</sm:includeIfEventAllowed>
	<tr>
		<td  class="VertSxAlta"><b>Presenza di indizi</b></td>
		<td  class="VertDxAlta" id = "presenzaDiIndiziTag" colspan="2"><%= presenzaDiIndizi %></td>
	</tr>
	<tr>
		<td  class="VertSxAlta"><b>Numero sicurezza sociale/TIN</b></td>
		<td  class="VertDxAlta" colspan="2"><%= numeroSicurezzaSociale %>&nbsp;</td>
	</tr>
	<tr id="w8BenRow" style="display:<%= ( "Y".equals(isUsOriginDatiIndirzzo) || "Y".equals(isUsOriginAll)) ? "none" : ""%>">
		<td class="VertSxAlta"><b>W8BEN</b> Certificate of Foreign Status of Beneficial Owner for United States Tax Withholding</td>
        <td class="VertDxAlta">
        <%
        if(isW8CertAllowed || modifica != null) {
        	if(w8) {
        		%><label id="w8Lebel">Si</label> <input type="hidden"  name="w8" value="on"><%
        	} else {
        		%>No<%
        	}
        } else {
        	%>No<%
        }
        %>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <%
        if (isW8CertAllowed) {
        %>
        
        	<sm:includeIfEventAllowed eventName="AcquisisciW8BEN" eventDescription="AcquisisciW8BEN">
            <input type="Button" name="AcquisisciW8BEN" value="Acquisisci W8BEN" onClick="disableAllButton();submitMe('AcquisisciW8BEN')" clasS="bottone"
            style="cursor:hand; display: <%= ( "Y".equals(isUsOriginDatiIndirzzo) || "Y".equals(isUsOriginAll)) ? "none" : ""%>"  >
            </sm:includeIfEventAllowed>
        </td>
        <%
        }%>
    </tr>
    <tr>
    	<td class="VertSxAlta"><b>W9</b> Request for Taxpayer Identification Number and Certification</td>
    	<td  class="VertDxAlta" colspan="2">
    		<%
    		if(isW9CertAllowed || modifica != null) {
    			if(w9) {
    				%><label id="w9Lebel"> Si </label> <input type="hidden"  name="w9" value="on"><%
    			} else {
    				%>No<%
    			}
    		} else {
    			%>No<%
    		}
    		%>
    	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    	<%
    	if(isW9CertAllowed) {
    		%>
    		
    			<sm:includeIfEventAllowed eventName="AcquisisciW9" eventDescription="AcquisisciW9">
    			<input type="Button"  name="AcquisisciW9" value="Acquisisci W9" onClick="disableAllButton();submitMe('AcquisisciW9')" clasS="bottone" style="cursor:hand; display: <%= ( "Y".equals( isUsOriginDatiIndirzzo ) || "Y".equals( isUsOriginAll )) ? "" : "none"%>" >
    			</sm:includeIfEventAllowed>
    		</td>
    		<%
    	}
    	%>
    </tr>
</table>
</td></tr></table>
<br>
<% } %>
<% if ( documentoErrorMessage != null )  { %>
<table width="100%" border="1" cellspacing="0" cellpadding="5" bordercolor="#CCCCCC" align="center">
	<tr>
		<td class="titolotab" height="35" align="left">
		<img src="/img/h2o/triangolo.gif" width="25" height="22" hspace="10" align="absmiddle"><%= documentoErrorMessage %></td>
	</tr>
</table>
<br>
<% } %>
<% if ( documentoCSErrorMessage != null || CSConformaWarningMessage!=null) { %>
<FORM name="AttributiFiscaliDocumentiForm" action="<sm:getMainURL/>" method="post">
<table width="760" border="1" cellspacing="0" cellpadding="5" bordercolor="#CCCCCC" align="center">
	<tr>
		<td class="titolotab" height="35" align="left">
			<img src="/img/h2o/news.gif" width="22" height="22" hspace="10" align="absmiddle"><%=documentoCSErrorMessage != null ?documentoCSErrorMessage : CSConformaWarningMessage  %>
		</td>
	</tr>
</table>
<br>
<% } %>
<% if ( CartaDocConformaWarningMessage!=null) { %>
<FORM name="AttributiFiscaliDocumentiForm" action="<sm:getMainURL/>" method="post">
<table width="760" border="1" cellspacing="0" cellpadding="5" bordercolor="#CCCCCC" align="center">
	<tr>
		<td class="titolotab" height="35" align="left">
			<img src="/img/h2o/news.gif" width="22" height="22" hspace="10" align="absmiddle"><%=CartaDocConformaWarningMessage%>
		</td>
	</tr>
</table>
<br>
<% } %>
<% if ( RRPSWarningMessage!=null) { %>
<FORM name="AttributiFiscaliDocumentiForm" action="<sm:getMainURL/>" method="post">
<table width="1000" border="1" cellspacing="0" cellpadding="5" bordercolor="#CCCCCC" align="center">
	<tr>
		<td class="titolotab" height="35" align="left">
			<img src="/img/h2o/news.gif" width="22" height="22" hspace="10" align="absmiddle"><%=RRPSWarningMessage%>
		</td>
	</tr>
</table>
<br>
<% } %>

<% if ( DataEmissioneWarningMessage!=null  ) { %>
<FORM name="AttributiFiscaliDocumentiForm" action="<sm:getMainURL/>" method="post">
<table width="1000" border="1" cellspacing="0" cellpadding="5" bordercolor="#CCCCCC" align="center">
	<tr>
		<td class="titolotab" height="35" align="left">
			<img src="/img/h2o/news.gif" width="22" height="22" hspace="10" align="absmiddle"><%=DataEmissioneWarningMessage%>
		</td>
		<td class="VertDxAlta"  >
					<select id="identification" name="identification" class="testocombo">
					  <option selected value= "--Select--">Seleziona
								<option  value="Si"  >Si</option>
								<option  value="No" >No</option>
						</select>
						
					</td>
		
	</tr>
</table>
<br>
<% } %>

<table class="topH2O" width="100%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
        	<table width="100%" bgColor="white">
            	<tr>
					<td class="titolotab"><b>Documento</b></td>
					<td colspan="4" class="titolotab" align="right">
						<input type="Button" name="DocumentiAggiungi" value="Aggiungi" style="cursor:hand" onClick="disableAllButton();submitMe('DocumentiAggiungi')" clasS="bottone">
					</td>
				</tr>
				<tr>
					<td class="VertSxAlta" width="50%">* Tipo Documento</td>
					<td class="VertDxAlta" width="50%" colspan="4">
						<select name="tipoDocumento" class="testocombo" onchange="disableAllButton();submitMe('DocRilasciatoDa')">
							<option selected value= "--Select--">Seleziona
<%  Collection tipoDocumentoCollection = CensBean.getCompatibleDocumenti();
	StringBuilder options = new StringBuilder();
	if ( tipoDocumentoCollection != null ) {
		Iterator iterator = tipoDocumentoCollection.iterator();
		CompDocumentView clView = null;
		int size = tipoDocumentoCollection.size();
		StringBuilder temp = new StringBuilder();
		boolean isPassPortAdded = false;
		for ( int i=0; i<size; i++ ) {
			clView = (CompDocumentView)iterator.next();
			if ( String.valueOf(clView.getClassificazioneId()).equals(tipoDocumento) ) {
				if(!isPassPortAdded || "PASES".equals(clView.getClassificazioneCausale())) {
					options.append("<option selected value=").append(clView.getClassificazioneId()).append(">").append(
							clView.getClassificazioneDescription());
				} else {
					temp.append("<option selected value=").append(clView.getClassificazioneId()).append(">").append(
							clView.getClassificazioneDescription());
				}
			} else {
				if(!isPassPortAdded || "PASES".equals(clView.getClassificazioneCausale())) {
					options.append("<option value=").append(clView.getClassificazioneId()).append(">").append(
							clView.getClassificazioneDescription());
				} else {
					temp.append("<option value=").append(clView.getClassificazioneId()).append(">").append(
							clView.getClassificazioneDescription());
				}

          	}
		  	if("Passaporto".equals(clView.getClassificazioneCausale())) {
				isPassPortAdded = true;
		  	}
		  
		}
		options.append(temp.toString());
	}
%>
						<%= options.toString() %>
						</select>
					</td>
				</tr>
                <tr>
					<td class="VertSxAlta">* Numero documento</td>
					<td class="VertDxAlta" colspan="4">
						<input type="text" name="numeroDocumento" maxlength ="16" value = "<%= numeroDocumento %>" class="testocombo">
                  	</td>
				</tr>
				<tr>
					<td class="VertSxAlta">* Rilasciato da</td>
					<td class="VertDxAlta" colspan="4">
						<input type="text" name="rilasciatoDa" maxlength = "40" value = "<%= rilasciatoDa %>" class="testocombo">
	                </td>
                </tr>
                <tr>
					<td rowspan="2" class="VertSxAlta">* Luogo del rilascio</td>
					<td class="VertSxAlta" nowrap="nowrap">* Nazione&nbsp;</td>
					<td class="VertSxAlta" colspan="2" nowrap="nowrap">* Citt&agrave;</td>
					<td class="VertSxAlta" colspan="1" nowrap="nowrap"><span id="proviciaTag" style="visibility: <%=isProvinciaDisable %>">* Provicia</span></td>
                </tr>
                <tr>
                	<td class="VertDxAlta" width="50%">
                		<select name="rilasciatoLuogoNazione" class="testocOmbo" onchange="submitMe('CittaDisable')">
                			<option selected value="Select">--Seleziona--</option>
                			<%
                			if("ITALIA".equals(tipoLuogoEmissione) || "ALL".equals(tipoLuogoEmissione)) {
                				Nazione nazioneItalia = CensBean.getNazione("ITALIA");
                				if(nazioneItalia != null) {
                					final String  isSelected = "ITALIA".equals(tipoLuogoEmissione) ? "selected" : "";
                					%>
                					<Option <%=isSelected %> value="<%= nazioneItalia.getNazioneId()+"^"+nazioneItalia.getCncf()+"^"+nazioneItalia.getNome()+"^"+nazioneItalia.getDocAggiuntivi() %>"><%= nazioneItalia.getNome()+(nazioneItalia.getCncf()!= null ? " - "+nazioneItalia.getCncf() : "")  %></Option>
                					<%
                				}
                			}
                			if("NON ITALIA".equals(tipoLuogoEmissione) || "ALL".equals(tipoLuogoEmissione)) {
                				for(Nazione nazione : (List<Nazione>)nazioneCollection) {
									if( (nazione.getCncf() != null && nazione.getCncf().equals(cncf)) || ( nazione.getCncf() == null && nazione.getNome().equals(rilasciatoLuogoNazione))) {
										%>
										<Option selected value="<%= nazione.getNazioneId()+"^"+nazione.getCncf()+"^"+nazione.getNome()+"^"+nazione.getDocAggiuntivi()%>"><%= nazione.getNome()+(nazione.getCncf() != null ? " - "+nazione.getCncf() : "")  %></Option>
										<%
									} else if(!"ITALIA".equals(nazione.getNome())) {
										%>
										<Option value="<%= nazione.getNazioneId()+"^"+nazione.getCncf()+"^"+nazione.getNome()+"^"+nazione.getDocAggiuntivi() %>"><%= nazione.getNome()+(nazione.getCncf() != null ? " - "+nazione.getCncf() : "")  %></Option>
										<%
									}
								}
                			}
							%>
                		</select>
					</td>
					<td colspan="2" class="VertDxAlta" nowrap="nowrap">
                		<input <%=isCittaDisable %> type="text" name="rilasciatoLuogoCitta" maxlength="40"  value="<%=rilasciatoLuogoCitta%>" class="testocombo">&nbsp;&nbsp;&nbsp;
                		<input <%=isCittaDisable %> type="Button" name="cercaDoc" value="Cerca" onClick="disableAllButton();submitMe('GeograficaLuogoEmissione')" style="cursor:hand" class="bottone">
                		
                	</td>
                	<td id="rilasciatoLuogoProvinciaId">
                		<%
                		if(collMultipleCitta != null && collMultipleCitta.size()> 0 && (!"".equals(rilasciatoLuogoProvincia) || collMultipleCitta.size() > 1 ) ) {
                			%>
                			<select name="rilasciatoLuogoProvincia" class="testocOmbo">
                				<Option selected value="Select">Select</Option>
                				<%
                				for(Citta citta : collMultipleCitta) {
                					if(rilasciatoLuogoProvincia.equals(citta.getProvincia().getSigla())) {
                						%>
                						<Option selected value="<%= citta.getProvincia().getSigla() %>"><%= citta.getProvincia().getSigla() %></Option>
                						<%
                					} else {
                						%>
                						<Option value="<%= citta.getProvincia().getSigla() %>"><%= citta.getProvincia().getSigla() %></Option>
                						<%
                					}
                				}
                				%>
                			</select>
                			<%
                		}
                		%>
                	</td>
                </tr>
                <tr>
					<td class="VertSxAlta">* Data del rilascio (gg/mm/aaaa)</td>
					<td class="VertDxAlta" colspan="4">
						<input type="text" name="rilasciatoDate" maxlength="2" size="2" value ="<%= rilasciatoDate %>" onBlur=" isDigit(this);" onchange="disableAllButton();submitScandenza('DocDataDiScandenza')" onKeyUp="changeFocusOffset (this, 2, 1)"  class="testocombo">&nbsp;/
						<input type="text" name="rilasciatoMonth" size="2" maxlength=2  value="<%= rilasciatoMonth %>"  onBlur=" isDigit(this);" onchange="disableAllButton();submitScandenza('DocDataDiScandenza')" onKeyUp="changeFocusOffset (this, 2, 1)"  class="testocombo">&nbsp;/
						<input type="text" name="rilasciatoYear" maxlength="4" size="4" value ="<%= rilasciatoYear %>" onBlur=" isDigit(this);" onchange="disableAllButton();submitScandenza('DocDataDiScandenza')" onKeyUp="changeFocusOffset (this, 4, 1)"  class="testocombo">
                  	</td>
                </tr>
                <tr>
                  	<td class="VertSxAlta">Data di scadenza (gg/mm/aaaa)</td>
                  	<td class="VertDxAlta" colspan="4" >
                 
                    	<input type="text" name="scadenzaDate" maxlength="2" size="2" value ="<%= scadenzaDate %>"  onBlur=" isDigit(this);" onKeyUp="changeFocusOffset (this, 2, 1)" class="testocombo" <%=isDisableScadenza %>>&nbsp;/
                    	<input type="text" name="scadenzaMonth" size="2" maxlength=2  value="<%= scadenzaMonth %>"   onBlur=" isDigit(this);" onKeyUp="changeFocusOffset (this, 2, 1)" class="testocombo" <%=isDisableScadenza %>>&nbsp;/
                    	<input  type="text" name="scadenzaYear" maxlength="4" size="4" value ="<%= scadenzaYear %>" onBlur=" isDigit(this);" onKeyUp="changeFocusOffset (this, 4, 0)" class="testocombo" <%=isDisableScadenza %>>
                  	
                  	</td>
                </tr>
			</table>

<%
	if ( documentoCollection != null && documentoCollection.size() > 0 )  {
   		boolean isPSRPSDocumentPresent = false;
   		boolean otherDocuments = false;
%>
        	<table bgColor="white" width="100%">
				<tr>
					<td colspan="11" class="titolotab" align="right">
						<sm:includeIfEventAllowed eventName="DocumentiElimina" eventDescription="DocumentiElimina">
							<input type="Button" name="DocumentiElimina" value="Elimina" style="cursor:hand" onClick="disableAllButton();submitMe('DocumentiElimina')" class="bottone">
						</sm:includeIfEventAllowed>
					</td>
				</tr>
<%
   		int size = documentoCollection.size();
		Iterator iterator = documentoCollection.iterator();
		DocumentoPFView documentoView = null;
		for ( int i=0; i<size; i++ ) {
			documentoView = (DocumentoPFView)iterator.next();
	 		if ( "Registrazione Tribunale".equals(documentoView.getTipoDocumento().getCausale()) ||
	 			 "RPS".equals(documentoView.getTipoDocumento().getCausale()) ||
	 			 "RRPS".equals(documentoView.getTipoDocumento().getCausale())||
	 			 "CRPS".equals(documentoView.getTipoDocumento().getCausale()) || 
	 			 "Green card".equals(documentoView.getTipoDocumento().getCausale()) ||"PS".equals(documentoView.getTipoDocumento().getCausale()) || ("CS".equals(documentoView.getTipoDocumento().getCausale()) && documentoView.getDataEmissione()!=null && new DateHandler().isDateMoreThanSpecifiedYears(documentoView.getDataEmissione(),ICensimentoPFConstants.DOC_PREFILL_SCANDENZA_CARATA_BEFORECOMP_YEAR))) {
				isPSRPSDocumentPresent = true;
	 		} else
	 				{
	 			otherDocuments = true;
	 		}
		}
		if ( otherDocuments ) {
%>
            	<tr>
            		<td class="VertDxAlta" colspan="11"><b><font color="red">Documenti validi ai fini dell'identificazione antiriciclaggio:</font></b></td>
            	</tr>
				<tr>
                	<td class="VertSxAlta">&nbsp;</td>
                	<td class="VertSxAlta">Data Inserimento</td>
                	<td class="VertSxAlta">Utente Inseritore</td>
					<td class="VertSxAlta">Tipo documento</td>
					<td class="VertSxAlta">Numero documento</td>
					<td class="VertSxAlta">Ente emissione</td>
					<td class="VertSxAlta">Luogo emissione</td>
					<td class="VertSxAlta">Data emissione</td>
					<td class="VertSxAlta">Data scadenza </td>
					<td class="VertSxAlta">ID scansione</td>
					<td class="VertSxAlta">&nbsp;</td>
					<td></td>
              	</tr>
<%
			iterator = documentoCollection.iterator();
			for ( int i=0; i<size; i++ ) {
				documentoView = (DocumentoPFView)iterator.next();
		 		if ( (documentoView.getDataFineValidita() == null || documentoView.getDocumentoId() == null ) && !"Registrazione Tribunale".equals(documentoView.getTipoDocumento().getCausale()) &&
		 			  !"RPS".equals(documentoView.getTipoDocumento().getCausale()) &&
		 			  !"RRPS".equals(documentoView.getTipoDocumento().getCausale()) &&
		 			  !"CRPS".equals(documentoView.getTipoDocumento().getCausale()) && 
		 			  !"Green card".equals(documentoView.getTipoDocumento().getCausale()) && !"PS".equals(documentoView.getTipoDocumento().getCausale()) && !("CS".equals(documentoView.getTipoDocumento().getCausale()) && documentoView.getDataEmissione()!=null && new DateHandler().isDateMoreThanSpecifiedYears(documentoView.getDataEmissione(),ICensimentoPFConstants.DOC_PREFILL_SCANDENZA_CARATA_BEFORECOMP_YEAR))) {

		 			String strDataEmissione = documentoView.getDataEmissione() != null ? new DateHandler().formatDate(documentoView.getDataEmissione(),"dd-MM-yyyy") : "";
					String strDataScadenza = documentoView.getDataScadenza() != null ? new DateHandler().formatDate(documentoView.getDataScadenza(),"dd-MM-yyyy") : "";
					String strDocInsertedDate = documentoView.getDocInsertedDate() != null ? new DateHandler().formatDate(documentoView.getDocInsertedDate(),"dd-MM-yyyy") : "";
%>
          		<tr>
            		<td class=VertDxAlta width="0%">
<% 					if ( i == 0 ) { %>
              			<input type="radio" name="documentoIndex" value="<%= String.valueOf(i) %>" checked>
<% 					} else { %>
              			<input type="radio" name="documentoIndex" value="<%= String.valueOf(i) %>">
<% 					} %> </td>
					<td class="VertDxAlta" ><%= strDocInsertedDate %>&nbsp;</td>
					<td class="VertDxAlta" ><%= documentoView.getDocInsertedUser() != null ? documentoView.getDocInsertedUser() : "" %>&nbsp;</td>
            		<td class="VertDxAlta" ><%= documentoView.getTipoDocumento().getDescrizione() %>&nbsp;</td>
            		<td class="VertDxAlta" ><%= documentoView.getDocumentoNumero() %>&nbsp;</td>
            		<td class="VertDxAlta" ><%= documentoView.getEnteEmissione() %>&nbsp;</td>
            		<td class="VertDxAlta" ><%= documentoView.getLuogoEmissione() %>&nbsp;</td>
            		<td class="VertDxAlta" ><%= strDataEmissione %>&nbsp;</td>
            		<td class="VertDxAlta" ><%= strDataScadenza %>&nbsp;</td>
            		<td class="VertDxAlta" ><%= documentoView.getIdDoc() %>&nbsp;</td>
					<td class="VertDxAlta" nowrap="nowrap">
            		<% if(documentoView.getIdDoc() != null || documentoView.getIssId()!=null) {%>
						<sm:includeIfEventAllowed eventName="UploadFiles" eventDescription="UploadFiles">
							<a href="javascript:submitMeAfterClickingImage('UploadFiles','<%= documentoView.getIdDoc()%>');" onMouseOver="link('Allega Documenti Identità');return true;" onMouseOut="cancella()">
                    		<img src="/H2O/HomePageClienteIntranet/img/docid.png" alt="Allega documento identità" border="0" width="29" height="19"></a>
                    	</sm:includeIfEventAllowed>
                <% } else {%>
                	 &nbsp;&nbsp;
                 <%} if(documentoView.getIssId()!=null) {%>
                    	<sm:includeIfEventAllowed eventName="viewDetails" eventDescription="viewDetails"> 
                    		<a href="javascript:submitMeAfterClickingImage('viewDetails', <%= documentoView.getIssId()%>);" onMouseOver="link('Iss');return true;" onMouseOut="cancella()">
                     		<img src="/x-net/img/ico_mydocs.gif" alt="Visualizza i documenti archiviati" border="0" ></a>
                      	</sm:includeIfEventAllowed>
                <%}%>
                   	</td>
          		</tr>
<% 				}
			}
		}
	if ( isPSRPSDocumentPresent ) {
%>
				<tr>
        			<td class="VertDxAlta" colspan="11"><b><font color="red">Documenti NON validi ai fini dell'identificazione antiriciclaggio:</font></b></td>
        		</tr>
        		<tr>
          			<td class="VertSxAlta">&nbsp;</td>
          			<td class="VertSxAlta">Data Inserimento</td>
          			<td class="VertSxAlta">Utente Inseritore</td>
          			<td class="VertSxAlta">Tipo Documento</td>
          			<td class="VertSxAlta">Numero Documento</td>
          			<td class="VertSxAlta">Ente Emissione</td>
          			<td class="VertSxAlta">Luogo Emissione</td>
          			<td class="VertSxAlta">Data Emissione</td>
          			<td class="VertSxAlta">Data Scadenza</td>
          			<td class="VertSxAlta">ID scansione</td>
          			<td class="VertSxAlta">&nbsp;</td>
        		</tr>
<%
				iterator = documentoCollection.iterator();
				DateHandler dateHandler = new DateHandler();
				for ( int i=0; i<size; i++ ) {
					documentoView = (DocumentoPFView)iterator.next();
					if ((documentoView.getDataFineValidita() == null || documentoView.getDocumentoId() == null) && ("Registrazione Tribunale".equals(documentoView.getTipoDocumento().getCausale()) ||
						 "RPS".equals(documentoView.getTipoDocumento().getCausale()) ||
						 "RRPS".equals(documentoView.getTipoDocumento().getCausale()) ||
						 "CRPS".equals(documentoView.getTipoDocumento().getCausale()) || "Green card".equals(documentoView.getTipoDocumento().getCausale()) || "PS".equals(documentoView.getTipoDocumento().getCausale()) || ("CS".equals(documentoView.getTipoDocumento().getCausale()) && documentoView.getDataEmissione()!=null && new DateHandler().isDateMoreThanSpecifiedYears(documentoView.getDataEmissione(),ICensimentoPFConstants.DOC_PREFILL_SCANDENZA_CARATA_BEFORECOMP_YEAR)))) {
						String strDataEmissione = documentoView.getDataEmissione() != null ? dateHandler.formatDate(documentoView.getDataEmissione(),"dd-MM-yyyy") : "";
						String strDataScadenza = documentoView.getDataScadenza() != null ? dateHandler.formatDate(documentoView.getDataScadenza(),"dd-MM-yyyy") : "";
						String strDocInsertedDate = documentoView.getDocInsertedDate() != null ? new DateHandler().formatDate(documentoView.getDocInsertedDate(),"dd-MM-yyyy") : "";
%>
          		<tr>
            		<td class=VertDxAlta width="0%">
<% 						if ( i == 0 ) { %>
              			<input type="radio" name="documentoIndex" value="<%= String.valueOf(i) %>" checked>
<% 						} else { %>
              			<input type="radio" name="documentoIndex" value="<%= String.valueOf(i) %>">
<% 						} %>
					</td>
					<td class="VertDxAlta" ><%= strDocInsertedDate %>&nbsp;</td>
					<td class="VertDxAlta" ><%= documentoView.getDocInsertedUser() != null ? documentoView.getDocInsertedUser() : "" %>&nbsp;</td>
					<td class="VertDxAlta" ><%= documentoView.getTipoDocumento().getDescrizione() %>&nbsp;</td>
					<td class="VertDxAlta" ><%= documentoView.getDocumentoNumero() %>&nbsp;</td>
					<td class="VertDxAlta" ><%= documentoView.getEnteEmissione() %>&nbsp;</td>
					<td class="VertDxAlta" ><%= documentoView.getLuogoEmissione() %>&nbsp;</td>
					<td class="VertDxAlta" ><%= strDataEmissione %>&nbsp;</td>
					<td class="VertDxAlta" ><%= strDataScadenza %>&nbsp;</td>
					<td class="VertDxAlta" ><%= documentoView.getIdDoc() %>&nbsp;</td>
					<td class="VertDxAlta" nowrap="nowrap">
					<% if(documentoView.getIdDoc() != null || documentoView.getIssId()!=null) {%>
							<sm:includeIfEventAllowed eventName="UploadFiles" eventDescription="UploadFiles">
								<a href="javascript:submitMeAfterClickingImage('UploadFiles','<%= documentoView.getIdDoc()%>');" onMouseOver="link('Allega Documenti Identità');return true;" onMouseOut="cancella()">
	                    		<img src="/H2O/HomePageClienteIntranet/img/docid.png" alt="Allega documento identità" border="0" width="29" height="19"></a>
	                    	</sm:includeIfEventAllowed>
                 	<% } else {%>
                		&nbsp;&nbsp;
                	<%} if(documentoView.getIssId()!=null) {%>
	                    	<sm:includeIfEventAllowed eventName="viewDetails" eventDescription="viewDetails"> 
	                    		<a href="javascript:submitMeAfterClickingImage('viewDetails', <%= documentoView.getIssId()%>);" onMouseOver="link('Iss');return true;" onMouseOut="cancella()">
	                     		<img src="/x-net/img/ico_mydocs.gif" alt="Visualizza i documenti archiviati" border="0" ></a>
	                      	</sm:includeIfEventAllowed>
	                   	
                <% } %>
          		</tr>
<%      			}
				}
        }
%>
        	</table>
<% 	} else { %>
        	<table bgColor="white" width="100%">
            	<tr>
            		<td class="VertDxAlta" colspan="11"><b><font color="red">Documenti validi ai fini dell'identificazione antiriciclaggio:</font></b></td>
            	</tr>
              	<tr>
					<td class="VertSxAlta">&nbsp;</td>
					<td class="VertSxAlta">Data Inserimento</td>
					<td class="VertSxAlta">Utente Inseritore</td>
					<td class="VertSxAlta">Tipo documento</td>
					<td class="VertSxAlta">Numero documento</td>
					<td class="VertSxAlta">Ente emissione</td>
					<td class="VertSxAlta">Luogo emissione</td>
					<td class="VertSxAlta">Data emissione</td>
					<td class="VertSxAlta">Data scadenza </td>
					<td class="VertSxAlta">ID scansione</td>
					<td class="VertSxAlta">&nbsp;</td>
					<td></td>
              	</tr>
              	<tr>
        			<td class="VertDxAlta" colspan="11"><b><font color="red">Documenti NON validi ai fini dell'identificazione antiriciclaggio:</font></b></td>
        		</tr>
        		<tr>
					<td class="VertSxAlta">&nbsp;</td>
					<td class="VertSxAlta">Data Inserimento</td>
					<td class="VertSxAlta">Utente Inseritore</td>
				  	<td class="VertSxAlta">Tipo Documento</td>
				  	<td class="VertSxAlta">Numero Documento</td>
				  	<td class="VertSxAlta">Ente Emissione</td>
				  	<td class="VertSxAlta">Luogo Emissione</td>
				  	<td class="VertSxAlta">Data Emissione</td>
				  	<td class="VertSxAlta">Data Scadenza</td>
				  	<td class="VertSxAlta">ID scansione</td>
					<td class="VertSxAlta">&nbsp;</td>
				  	<td></td>
        		</tr>
			</table>
<% 	} %>
		</td>
	</tr>
	

	<tr>
<td>
        	<table width="100%" bgColor="white">
            	<tr>
					<td class="VertSxAlta">* Modalita di identificazione del cliente</td>
					<td class="VertDxAlta" align="right">
					<select name="modalita" class="testocombo">
					  <option selected value= "--Select--">Seleziona
						<%
					if ( modalitaCollection != null ) {
						 ClassificazioneView classificazioneView = null;
							for (Object classficazioneObj : modalitaCollection) {
							     classificazioneView = (ClassificazioneView) classficazioneObj;
							      if (!ICensimentoPFConstants.MODALITA_SEMPLIFICATA.equals(classificazioneView.getCausale()) && !ICensimentoPFConstants.MODALITA_TRAMITE_POSTE.equals(classificazioneView.getCausale())) {%> 
							     <option <%=(!"".equals(modalita) && !"--Select--".equals(modalita) && classificazioneView.getId().equals(Long.valueOf(modalita)) ) ? "selected" :""%>
							      value= "<%= classificazioneView.getId() %>"><%= classificazioneView.getDescrizione()%>
							<%} }%>
							</option>
							<%}
						%>

						</select>
					</td>
			</tr>
</table>
</td>
</tr>
</table>
<br>

<table width="100%" border="0" cellspacing="0" cellpadding="1">
    <tr>
<% if ( modifica == null ) { %>
	    <td width="33%" align="center">
			<input type="Button" name="Annulla" value="Annulla" style="cursor:hand" onClick="disableAllButton();submitMe('Annulla')">
		</td>
      	<td width="33%" align="center">
        	<input type="Button" name="AFDIndietro" value="Indietro" style="cursor:hand" onClick="disableAllButton();submitMe('AFDIndietro')">
        </td>
<% } else { %>
      	<td width="33%" align="center">&nbsp;</td>
	    <td width="33%" align="center">
        	<input type="hidden" name="Modifica" value="M">
           	<input type="Button" name="AFDAnnulla" value="Annulla" style="cursor:hand" onClick="disableAllButton();submitMe('AFDAnnulla')">
		</td>
<% } %>
	    <input type="hidden" name="hiddenSconf" value="<%= hiddenSconf %>" >
      	<td width="33%" align="center">
      		<sm:includeIfEventAllowed eventName="Conferma" eventDescription="Conferma">
	        		<input type="Submit" name="<sm:getEventParamName/>" value="<sm:getEventParamValue/>" style="cursor:hand" onclick="disableAllButton();return submitForm()" >
        	</sm:includeIfEventAllowed>
        </td>
	</tr>
</table>
<% if ( isSessoReadOnly ) { %>
	<input type="hidden" name="SESSO_READONLY" value="true">
<% } %>
<% if ( CSConformaWarningMessage != null) { %>
	<input type="hidden" name="hiddenCSWarnMsg" value="true">
<% }%>
<%
if(CartaDocConformaWarningMessage != null){%>
<input type="hidden" name="hiddenCartaDocWarnMsg" value="true">
<%}%>
<input type="hidden" name="settore" value="<%= settore  %>">
<input type="hidden" name="ramo" value="<%= ramo  %>">
<input type="hidden" name="isUsOriginDatiIndirzzo" value="<%=isUsOriginDatiIndirzzo%>">
<input type="hidden" name="isUsOriginAll" value="<%=isUsOriginAll%>">
<input type="hidden" name="isFormSubmiited" value="">
<input type="hidden" name="frimagraf" value="<%=frimagraf != null ? frimagraf :""%>">
<input type="hidden" name="frimadata" value="<%= frimadata !=null ? frimadata:"" %>">
<input type="hidden" name="GEOGRAFICA_RICERCA_FOR" value="" />
<input type="hidden" name= "w9NoReasonCertificate" value="<%=w9NoReasonCertificate%>">
<input type="hidden" name= "isUsCollegate" value="<%=isUsOriginCollegate%>">
<input type="hidden" id="ident" name= "ident" value="<%=ident%>">
	<% if("disabled".equals(isDisableScadenza)){%>
                    	<input type="hidden" name="scadenzaDateI"  value ="<%= scadenzaDate %>"    >
                    	<input type="hidden" name="scadenzaMonthI"  value="<%= scadenzaMonth %>"   >
                    	<input  type="hidden" name="scadenzaYearI"  value ="<%= scadenzaYear %>"  >
                    <%}  %>

</form>
</body>

	