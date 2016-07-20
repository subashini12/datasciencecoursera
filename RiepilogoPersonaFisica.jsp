<%@page import="java.util.ArrayList"%>
<%@ taglib uri="/statemachine.tld" prefix="sm"%>
<%@ page import = "
				 java.util.Hashtable,
				 java.util.Collection,
				 java.util.Iterator,
				 java.util.StringTokenizer,
                 it.sella.anagrafe.logView.LogView,
                 it.sella.anagrafe.sviluppatore.RicercaSviluppatoreView,
                 it.sella.anagrafe.util.ExecuterHelper,
                 it.sella.anagrafe.originecliente.OrigineClienteView,
                 it.sella.statemachine.View,
                 it.sella.anagrafe.implementation.InformazioneManager,
                 it.sella.anagrafe.pf.*,
                 it.sella.anagrafe.sm.censimentopf.ICensimentoPFConstants,
                 it.sella.anagrafe.dipendente.RicercaDipendenteView,
                 it.sella.anagrafe.promotore.RicercaPromotoreView,
                 it.sella.anagrafe.implementation.MemoView,
                 it.sella.anagrafe.util.AnagrafeHelper,
                 it.sella.anagrafe.util.DateHandler,
                 it.sella.anagrafe.IDocPoteriFirmaView,
                 it.sella.anagrafe.CanalePreferitoDataView,
                 it.sella.anagrafe.ICanaleUtilizzatoView,
                 it.sella.anagrafe.IDAIRegoleDetailsView,
                 it.sella.anagrafe.SoggettoDAIDataView"
%>

<jsp:useBean id="CensBean" class="it.sella.anagrafe.webbean.censimento_pf.CensimentoPFBean" scope="application" />

<%!
	private String buildCodiceHost(String codiceHost) {
		StringBuffer codiceHostBuffer = new StringBuffer("");
		if ( codiceHost != null && codiceHost.trim().length() > 1 ) {
			String[] tt = codiceHost.split(";");
			int length = tt.length;
			int count = 0;
			if( length == 1 ) {
				codiceHostBuffer.append(tt[0]);
			} else  {
				for(int i=0; i<length; i++) {
					count = count+1;
					codiceHostBuffer.append(tt[i]).append(";");
					if( count == 7 ) {
						count = 0;
						codiceHostBuffer.append("<br>");
					}
			   }
		   }
	    }
		return codiceHostBuffer.toString();
	}
%>


<%
    InformazioneManager informazioneManager = null;
    DatiAnagraficiPFView datiAnagraficiView = null;
    AttributiEsterniPFView attributiEsterniView = null;
    IndirizzoPFView indirizzoResidenzaView = null;
    IndirizzoPFView indirizzoDomicilioView = null;
    DatiFiscaliPFView datiFiscaliView = null;
    DatiPrivacyPFView datiPrivacyPFView = null;
    DatiPrivacyPFFiveLevelView datiPrivacyPFFiveLevelView = null;
    DocumentoPFView documentoView = null;
    SoggettoRecapitiView recapitiView = null;
    SoggettoEventoView eventoView=null;
    MemoView memoView=null;
    CodiceSoggettoPFView codiceSoggettoPFView = null;

    Collection documentoCollection = null;
    Collection recapitiCollection = null;
    Collection eventoViewCollection = null;
    Collection memoViewCollection = null;
    Hashtable collegateViews = null;
    Collection dipendenteCollection = null;
    Collection promotoreCollection = null;
    Collection sviluppatoreCollection = null;
    Collection logViews = null;
    OrigineClienteView origineClienteView = null ;
    boolean clienteIndirettoCheck = false;

    View view = (View)session.getAttribute("view");
    String modifica = (String)view.getOutputAttribute("Modifica");
    String strErrorMsg = (String)view.getOutputAttribute("strErrorMsg");
    String strSvilpError = (String)view.getOutputAttribute("strSvilpError");
    String datiFiscaliError = (String)view.getOutputAttribute("datiFiscaliError");
    String documentoError = (String)view.getOutputAttribute("documentoError");
    String attributiEsterniError = (String)view.getOutputAttribute("attributiEsterniError");
    String eventiError = (String)view.getOutputAttribute("eventiError");
    String intermediariError = (String)view.getOutputAttribute("intermediariError");
    String datiAnagraficiError = (String)view.getOutputAttribute("datiAnagraficiError");
    String indirizzoPageError = (String)view.getOutputAttribute("indirizzoError");
    String recapitiError = (String)view.getOutputAttribute("recapitiError");
    String datiPrivacyError = (String)view.getOutputAttribute("datiPrivacyError");
    String collegateError = (String)view.getOutputAttribute("collegateError");
    String codiciSoggettoError = (String)view.getOutputAttribute("codiciSoggettoError");
    String segnalatoreError = (String)view.getOutputAttribute("segnalatoreError");
    String poteriFirmaErrorMessage = (String)view.getOutputAttribute("PoteriFirmaErrorMessage");
    String canalePreferitoError = (String)view.getOutputAttribute("canalePreferitoError");
    String residenzaFisWarning = (String)view.getOutputAttribute("ResidenzaFisWarning");
    
    String isUsOriginDatiIndirzzo = view.getOutputAttribute( ICensimentoPFConstants.ISUSORIGIN_DATIIINDIRZZ0 ) != null ? (String) view.getOutputAttribute( ICensimentoPFConstants.ISUSORIGIN_DATIIINDIRZZ0 ) : "";
    String isUsOriginAll = view.getOutputAttribute( ICensimentoPFConstants.ISUSORIGIN_ALL ) != null ? (String) view.getOutputAttribute( ICensimentoPFConstants.ISUSORIGIN_ALL ) : "";
    String isUsOriginCollegate = view.getOutputAttribute( "IS_US_COLLEGATE" ) != null ? (String) view.getOutputAttribute( "IS_US_COLLEGATE" ) : "";

    boolean showModify = true ;
    if( strSvilpError != null ) {
    	showModify = false;
    }

    Long idForModifica = view.getOutputAttribute("CENSIMENTOPF_FOR_COLLEGATE") != null ?
    		(Long) view.getOutputAttribute("Soggetto_Id") : (Long) view.getOutputAttribute("SOGGETTO_FOR_MODIFICATION");
	Boolean isEmployee = (Boolean)view.getOutputAttribute("IsEmployee") ;

    informazioneManager = (InformazioneManager)view.getOutputAttribute("IMANAGER");
    if( informazioneManager != null ) {
    	CensBean.setInformazioneManager(informazioneManager);
    }
    String plMenuCheck = (String)view.getOutputAttribute("CENSIMENTOPF_ISFORPL");
    String isCollegateDisplayed = (String)view.getOutputAttribute("DISPLAY_COLLEGATE");

    datiAnagraficiView  = (DatiAnagraficiPFView)view.getOutputAttribute(ICensimentoPFConstants.DATI_ANAGRAFICI_PF_VIEW_SESSION);
    attributiEsterniView = (AttributiEsterniPFView)view.getOutputAttribute(ICensimentoPFConstants.ATTRIBUTI_ESTERNI_PF_VIEW_SESSION);
    indirizzoResidenzaView = (IndirizzoPFView)view.getOutputAttribute(ICensimentoPFConstants.INDIRIZZO_RESIDENZA_PF_VIEW_SESSION);
    indirizzoDomicilioView = (IndirizzoPFView)view.getOutputAttribute(ICensimentoPFConstants.INDIRIZZO_DOMICILIO_PF_VIEW_SESSION);
    datiFiscaliView = (DatiFiscaliPFView) view.getOutputAttribute(ICensimentoPFConstants.DATI_FISICALI_PF_VIEW_SESSION);
    datiPrivacyPFView = (DatiPrivacyPFView)view.getOutputAttribute(ICensimentoPFConstants.DATI_PRIVACY_PF_VIEW_SESSION);
    datiPrivacyPFFiveLevelView = (DatiPrivacyPFFiveLevelView)view.getOutputAttribute(ICensimentoPFConstants.DATI_PRIVACY_PF_FIVELEVEL_VIEW_SESSION);

    documentoCollection = (Collection)view.getOutputAttribute(ICensimentoPFConstants.DOCUMENTI_PF_VIEW_SESSION);
    recapitiCollection = (Collection)view.getOutputAttribute(ICensimentoPFConstants.RECAPITI_PF_VIEW_SESSION);
    eventoViewCollection = (Collection)view.getOutputAttribute(ICensimentoPFConstants.EVENTI_PF_VIEW_SESSION);
    memoViewCollection = (Collection) view.getOutputAttribute(ICensimentoPFConstants.MEMO_PF_VIEW_SESSION);
    codiceSoggettoPFView = (CodiceSoggettoPFView)view.getOutputAttribute(ICensimentoPFConstants.CODICESOGGETTO_PF_VIEW_SESSION);
    dipendenteCollection = (Collection)view.getOutputAttribute(ICensimentoPFConstants.DIPENTE_VIEW_SESSION);
    promotoreCollection = (Collection)view.getOutputAttribute(ICensimentoPFConstants.PROMOTORE_VIEW_SESSION);
    sviluppatoreCollection = (Collection)view.getOutputAttribute(ICensimentoPFConstants.SVILUPPATORE_VIEW_SESSION);
    origineClienteView = (OrigineClienteView) view.getOutputAttribute(ICensimentoPFConstants.ORIGINECLIENTE_VIEW_SESSION) ;
    String apivacausale =  (String)view.getOutputAttribute("apivacausale") ;
	String apivadescrip =  (String)view.getOutputAttribute("apivadescrip") ;
    logViews = (Collection)view.getOutputAttribute("LOG_VIEWS");
    if( !"NO".equals(isCollegateDisplayed) ) {
      collegateViews=(Hashtable)view.getOutputAttribute(ICensimentoPFConstants.COLLEGATE_PF_VIEW);
    }
    String strDescrizione = "";
    String settoreCommerciale="";
    int size = -1;
    Collection motivCollection = (Collection)view.getOutputAttribute("MOTIVI");
    String daiValue = (String)view.getOutputAttribute("DAI_VALUE");
    final String A97_3bar46_link =(String)request.getAttribute("A97_3bar46_link");
	final String A97_6bar46_link=(String)request.getAttribute("A97_6bar46_link");
	final AnagrafeHelper helper = new AnagrafeHelper();
	CanalePreferitoDataView canalePreferitoView = (CanalePreferitoDataView)view.getOutputAttribute(ICensimentoPFConstants.CANALE_PREFERITO_PF_VIEW);
	ICanaleUtilizzatoView canaleUtilizzatoView = (ICanaleUtilizzatoView)view.getOutputAttribute(ICensimentoPFConstants.CANALE_UTILIZZATO_PF_VIEW); 
	String canaleDisplayVal = "Nessuna Preferenza";
    if(canalePreferitoView != null && canalePreferitoView.getCanale() != null) {
    	canaleDisplayVal = canalePreferitoView.getCanale().getDescrizione();
    	if(canalePreferitoView.getCanaleValue() != null) {
    		canaleDisplayVal = canaleDisplayVal + " - " + canalePreferitoView.getCanaleValue();
    	}
    }
    final Boolean profilPrivacyApplicable =  view.getOutputAttribute("DATIPRIV_PROFIL_APPLICABLE") != null ? (Boolean) view.getOutputAttribute("DATIPRIV_PROFIL_APPLICABLE") : Boolean.FALSE;
	final DatiPrivacyPFFiveLevelView privFivelevelDisplay =  (DatiPrivacyPFFiveLevelView) view.getOutputAttribute("DATIPRIV_FIVELEVEL_DISPLAY");
	final LogView privacyLogView =  (LogView) view.getOutputAttribute("DATIPRIV_FIVELEVEL_LOGVIEW");
	boolean showPrivacyLogData = false;
	
	final Boolean newDAIAllowed  =  view.getOutputAttribute("NEWDAI_ALLOWED") != null ? (Boolean) view.getOutputAttribute("NEWDAI_ALLOWED") : Boolean.FALSE;
	final Collection<IDAIRegoleDetailsView> daiRegoleColl = (Collection<IDAIRegoleDetailsView>) view.getOutputAttribute("DAI_REGOLE_DATA");
	final String daiAnagrafeValue = (String) view.getOutputAttribute("DAI_ANAGRAFE_DATA");
	
	final Collection<IDAIRegoleDetailsView> daiKOList = (Collection<IDAIRegoleDetailsView>)view.getOutputAttribute("REGOLE_DAIKO_LIST");
	final Collection<IDAIRegoleDetailsView> daiAlertList = (Collection<IDAIRegoleDetailsView>)view.getOutputAttribute("REGOLE_DAIALERT_LIST");
	
	final String bloccoMsg = view.getOutputAttribute("BLOCCO_DISPLAY_MSG") != null ? (String)view.getOutputAttribute("BLOCCO_DISPLAY_MSG") : "";
	final String alertMsg = view.getOutputAttribute("ALERT_DISPLAY_MSG") != null ? (String)view.getOutputAttribute("ALERT_DISPLAY_MSG") : "";
	
	final String daiOk = view.getOutputAttribute("DAIOK_STATUS_DESC") != null ? (String)view.getOutputAttribute("DAIOK_STATUS_DESC") : "";
	final String daiAlert = view.getOutputAttribute("DAIALERT_STATUS_DESC") != null ? (String)view.getOutputAttribute("DAIALERT_STATUS_DESC") : "";
	final String daiKo = view.getOutputAttribute("DAIKO_STATUS_DESC") != null ? (String)view.getOutputAttribute("DAIKO_STATUS_DESC") : "";
	
	
%>

<script type="text/javascript" src="/script/Anagrafe/jquery-1.10.2.min.js"></script>
<SCRIPT LANGUAGE="JavaScript">

    function submitMe(checkString) {

       if(checkString == "DatiAnagraficiModificaNotSec") {
           		<sm:includeIfEventAllowed eventName="DatiAnagraficiModificaNotSec" >
                   document.RiepilogoPersonaFisica.action = "<sm:getEventMainURL/>";
                   document.RiepilogoPersonaFisica.submit() ;
            	</sm:includeIfEventAllowed>
       } else if(checkString == "DatiAnagraficiModifica") {
	            <sm:includeIfEventAllowed eventName="DatiAnagraficiModifica" >
                   document.RiepilogoPersonaFisica.action = "<sm:getEventMainURL/>";
                   document.RiepilogoPersonaFisica.submit() ;
            	</sm:includeIfEventAllowed>
       } else if(checkString == "IndirizziRecapitiPrivacyModifica") {
            <sm:includeIfEventAllowed eventName="IndirizziRecapitiPrivacyModifica" >
                   document.RiepilogoPersonaFisica.action = "<sm:getEventMainURL/>";
                   document.RiepilogoPersonaFisica.submit() ;
            </sm:includeIfEventAllowed>
        } else if(checkString == "StampePrivacyPrint") {
            <sm:includeIfEventAllowed eventName="DatiPrivacyPdfPrint" >
                   document.RiepilogoPersonaFisica.action = "<sm:getEventMainURL/>";
                   document.RiepilogoPersonaFisica.submit() ;
            </sm:includeIfEventAllowed>
        } else if(checkString == "AttributiFiscaliDocumentiModifica") {
            <sm:includeIfEventAllowed eventName="AttributiFiscaliDocumentiModifica" >
                   document.RiepilogoPersonaFisica.action = "<sm:getEventMainURL/>";
                   document.RiepilogoPersonaFisica.submit() ;
            </sm:includeIfEventAllowed>
        } else if(checkString == "CollegateAggiungi") {
          <sm:includeIfEventAllowed eventName="CollegateAggiungi" >
                   document.RiepilogoPersonaFisica.action = "<sm:getEventMainURL/>";
                   document.RiepilogoPersonaFisica.submit() ;
          </sm:includeIfEventAllowed>
        } else if(checkString == "IntermediariEventiMemoModifica") {
            <sm:includeIfEventAllowed eventName="IntermediariEventiMemoModifica" >
                   document.RiepilogoPersonaFisica.action = "<sm:getEventMainURL/>";
                   document.RiepilogoPersonaFisica.submit() ;
            </sm:includeIfEventAllowed>
        } else if(checkString == "RPFIndietro") {
           <sm:includeIfEventAllowed eventName="RPFIndietro" >
                   document.RiepilogoPersonaFisica.action = "<sm:getEventMainURL/>";
                   document.RiepilogoPersonaFisica.submit() ;
           </sm:includeIfEventAllowed>
        } else if(checkString == "Annulla") {
           <sm:includeIfEventAllowed eventName="Annulla" >
                   document.RiepilogoPersonaFisica.action = "<sm:getEventMainURL/>";
                   document.RiepilogoPersonaFisica.submit() ;
           </sm:includeIfEventAllowed>
        } else if(checkString == "CalcolaDai") {
           <sm:includeIfEventAllowed eventName="CalcolaDai" >
                   document.RiepilogoPersonaFisica.action = "<sm:getEventMainURL/>";
                   document.RiepilogoPersonaFisica.submit() ;
           </sm:includeIfEventAllowed>
        }  else if(checkString == "ConfermaModifica") {
           <sm:includeIfEventAllowed eventName="ConfermaModifica">
                   document.RiepilogoPersonaFisica.action = "<sm:getEventMainURL/>";
                   document.RiepilogoPersonaFisica.submit() ;
           </sm:includeIfEventAllowed>
        }  else if(checkString == "ConfermaSocket") {
           <sm:includeIfEventAllowed eventName="ConfermaSocket">
                   document.RiepilogoPersonaFisica.action = "<sm:getEventMainURL/>";
                   document.RiepilogoPersonaFisica.submit() ;
           </sm:includeIfEventAllowed>
        } else if(checkString == "Create8Cifre") {
           <sm:includeIfEventAllowed eventName="Create8Cifre">
                   document.RiepilogoPersonaFisica.action = "<sm:getEventMainURL/>";
                   document.RiepilogoPersonaFisica.submit() ;
           </sm:includeIfEventAllowed>
        }else if(checkString == "SegnalatoreModifica") {
           <sm:includeIfEventAllowed eventName="SegnalatoreModifica">
                   document.RiepilogoPersonaFisica.action = "<sm:getEventMainURL/>";
                   document.RiepilogoPersonaFisica.submit() ;
           </sm:includeIfEventAllowed>
        }else if(checkString == "ManageRecapiti") {
           <sm:includeIfEventAllowed eventName="ManageRecapiti">
                   document.RiepilogoPersonaFisica.action = "<sm:getEventMainURL/>";
                   document.RiepilogoPersonaFisica.submit() ;
           </sm:includeIfEventAllowed>
        }
		else if(checkString == "CronistoriaVariazioni") {
          <sm:includeIfEventAllowed eventName="CronistoriaVariazioni">
                 document.RiepilogoPersonaFisica.action = "<sm:getEventMainURL/>";
                 document.RiepilogoPersonaFisica.submit() ;
          </sm:includeIfEventAllowed>
      } else if(checkString == 'CronistoriaPoteriFirma') {
    	  <sm:includeIfEventAllowed eventName="CronistoriaPoteriFirma">
          	document.RiepilogoPersonaFisica.action = "<sm:getEventMainURL/>";
          	document.RiepilogoPersonaFisica.submit() ;
   		  </sm:includeIfEventAllowed>
      } else if(checkString == 'CronistoriaDocumenti') {
    	  <sm:includeIfEventAllowed eventName="CronistoriaDocumenti">
        	document.RiepilogoPersonaFisica.action = "<sm:getEventMainURL/>";
        	document.RiepilogoPersonaFisica.submit() ;
 		  </sm:includeIfEventAllowed>
   	 }
    }

    function submitMeAfterClickingImage( checkString , code ) {
        if( checkString == "viewDetails" ) {
             <sm:includeIfEventAllowed eventName="viewDetails" >
       	       document.RiepilogoPersonaFisica.action = "<sm:getEventMainURL/>&isscode="+code;
	           document.RiepilogoPersonaFisica.submit() ;
              </sm:includeIfEventAllowed>
        }else if(checkString == "UploadFiles"){
        	<sm:includeIfEventAllowed eventName="UploadFiles" >
    	       document.RiepilogoPersonaFisica.action = "<sm:getEventMainURL/>&IdScansione="+code;
	           document.RiepilogoPersonaFisica.submit() ;
           </sm:includeIfEventAllowed>
        }
    }
    
    $(document).ready(function(){
    	
    	$('.regoleAlert').each(function(){
    		var daiType = $(this).attr('daiType');
    		var weightageColor = $(this).attr('weightageColor');
    		if($('#'+daiType) != undefined) {
    			$('.'+daiType).css('background-color', weightageColor);
    		}
    	});
    	
    	$('.regoleKO').each(function(){
    		var daiType = $(this).attr('daiType');
    		var weightageColor = $(this).attr('weightageColor');
    		if($('#'+daiType) != undefined) {
    			$('.'+daiType).css('background-color', weightageColor);
    		}
    	});
    });
</SCRIPT>

<style>
.daiOktab {
	FONT-SIZE: 13px;
	COLOR: Black;
	LINE-HEIGHT: 2px;
	FONT-FAMILY: Arial;
	background: #CCCCCC;
	padding: 2px;
	border-radius: 0px 0px 0px 0px;
	border: 0px;
	vertical-align: middle;
	height	:	50px;
}

.daiKOtab {
	FONT-SIZE: 12px;
	COLOR: Black;
	LINE-HEIGHT: normal;
	FONT-FAMILY: Arial;
	background: #FAE2D9;
	padding: 4px;
	border-radius: 0px 0px 0px 0px;
	border: 0px;
	vertical-align: middle;
}

.daiAlerttab {
	FONT-SIZE: 12px;
	COLOR: Black;
	LINE-HEIGHT: normal;
	FONT-FAMILY: Arial;
	background: #F9F9BD;
	padding: 4px;
	border-radius: 0px 0px 0px 0px;
	border: 0px;
	vertical-align: middle;
}

</style>

<% if( plMenuCheck != null ) { %>
<table width="100%" border="1" cellspacing="0" cellpadding="0"
	bordercolor="003366">
	<tr>
		<td height="31"><jsp:include page="/H2O/CensimentoPF/CensimentoPF.IndicatoreStato.jsp" /></td>
	</tr>
</table>
<br>
<% } %>
<form method="post" action="<sm:getMainURL/>" name="RiepilogoPersonaFisica">

<table width="100%">
	<tr>
		<td width="100%" class="testoContatti">Anagrafica - Censimento Persona Fisica</td>
	</tr>
</table>
<br>

<% if(strSvilpError != null) { %>
<table width="100%" border="1" cellspacing="0" cellpadding="5"
	bordercolor="#CCCCCC" align="center">
	<tr>
		<td class="titolotab" height="35" align="left"><img
			src="/img/h2o/triangolo.gif" width="25" height="22" hspace="10"
			align="absmiddle"><%= strSvilpError %></td>
	</tr>
</table>
<br>

<% } %> <% if(strErrorMsg != null) { %>
<table width="100%" border="1" cellspacing="0" cellpadding="5"
	bordercolor="#CCCCCC" align="center">
	<tr>
		<td class="titolotab" height="35" align="left">
			<img src="/img/h2o/triangolo.gif" width="25" height="22" hspace="10" align="absmiddle">
			<%= strErrorMsg %>
		</td>
	</tr>
</table>
<br>
<% } %>

<%
if(newDAIAllowed != null && newDAIAllowed) { %>

	<% if("DAIOK".equals(daiAnagrafeValue)) { %>
		<table width="100%" border="1" cellspacing="0" cellpadding="5" bordercolor="#CCCCCC" align="center">
			<tr>
				<td class="daiOktab" align="center" width="15%">&nbsp;</td>
				<td class="daiOktab" align="left" width="75%" style="font-weight: bold;">DATI ANAGRAFICI INCOMPLETI  -  <font color="green"><%=daiOk%></font> </td>
				<td class="daiOktab" align="center" width="10%"><input type="Button" name="CalcolaDai" value="Aggiorna" style="cursor:hand" onClick="submitMe('CalcolaDai')" class="bottone"></td>
			</tr>
		</table>
		<br>
	<%}%>
	
	<% if("DAIKO".equals(daiAnagrafeValue) && (daiKOList != null && !daiKOList.isEmpty())) { %>
		<table width="100%" border="1" cellspacing="0" cellpadding="5" bordercolor="#CCCCCC" align="center">
			<tr>
				<td class="daiKOtab" align="center" width="15%" rowspan="<%=(1+daiKOList.size())%>"><img src="/img/Anagrafe/triangolo_errore.gif" width="35" height="32" hspace="10" align="absmiddle"></td>
				<td class="daiKOtab" align="left" width="75%" style="font-weight: bold;font-size: 13px;" colspan="2">DATI ANAGRAFICI INCOMPLETI  &nbsp;&nbsp;-&nbsp;&nbsp;  <font color="red"><%=daiKo%></font>
				<br><span style="font-weight: normal;"><%=bloccoMsg%></span></td>
				<td class="daiKOtab" align="center" width="10%" rowspan="<%=(1+daiKOList.size())%>"><input type="Button" name="CalcolaDai" value="Aggiorna" style="cursor:hand" onClick="submitMe('CalcolaDai')" class="bottone"></td>
			</tr>
			<%
				for (IDAIRegoleDetailsView regoleView : daiKOList) {
					final String daiGroupDesc = (regoleView.getDaiPeso() != null && regoleView.getDaiPeso().getDaiGroupType() != null && regoleView.getDaiPeso().getDaiGroupType().getDaiDescription() != null) ? regoleView.getDaiPeso().getDaiGroupType().getDaiDescription() : "";
					final String daiDatiType = (regoleView.getDaiPeso() != null && regoleView.getDaiPeso().getDaiCode() != null && regoleView.getDaiPeso().getDaiCode().getDaiConfigCode() != null) ? regoleView.getDaiPeso().getDaiCode().getDaiConfigCode() : "";
					final String daiCodeDesc = (regoleView.getDaiCodeId() != null && regoleView.getDaiCodeId().getWeightCodeDescription() != null) ? regoleView.getDaiCodeId().getWeightCodeDescription() : "";
					%>
						<tr>
							<td class="daiKOtab" align="left" width="10%" nowrap="nowrap"><%=daiGroupDesc%></td>
							<td class="daiKOtab" align="left" width="65%" nowrap="nowrap">- &nbsp;&nbsp;<span class="regoleKO" daiType="<%=daiDatiType%>" weightageColor="#FAE2D9" style="text-decoration: underline;"><%=daiCodeDesc%></span></td>
						</tr>
					<%
				}
			%>
		</table>
		<br>
	<%}%>
	
	<% if("DAIALERT".equals(daiAnagrafeValue) || (daiAlertList != null && !daiAlertList.isEmpty())) { %>
		<table width="100%" border="1" cellspacing="0" cellpadding="5" bordercolor="#CCCCCC" align="center">
			<tr>
				<td class="daiAlerttab" align="center" width="15%" rowspan="<%=(1+daiAlertList.size())%>"><img src="/img/h2o/triangolo.gif" width="35" height="32" hspace="10" align="absmiddle"></td>
				<td class="daiAlerttab" align="left" width="75%" style="font-weight: bold;font-size: 13px;" colspan="2">DATI ANAGRAFICI INCOMPLETI&nbsp;&nbsp;  - &nbsp;&nbsp; <font color="#EB5321"><%=daiAlert%></font>
					<br><span style="font-weight: normal;"><%=alertMsg%></span>
				</td>
				<td class="daiAlerttab" align="center" width="10%" rowspan="<%=(1+daiAlertList.size())%>"><input type="Button" name="CalcolaDai" value="Aggiorna" style="cursor:hand" onClick="submitMe('CalcolaDai')" class="bottone"></td>
			</tr>

			<%
				for (IDAIRegoleDetailsView regoleView : daiAlertList) {
					final String daiGroupDesc = (regoleView.getDaiPeso() != null && regoleView.getDaiPeso().getDaiGroupType() != null && regoleView.getDaiPeso().getDaiGroupType().getDaiDescription() != null) ? regoleView.getDaiPeso().getDaiGroupType().getDaiDescription() : "";
					final String daiDatiType = (regoleView.getDaiPeso() != null && regoleView.getDaiPeso().getDaiCode() != null && regoleView.getDaiPeso().getDaiCode().getDaiConfigCode() != null) ? regoleView.getDaiPeso().getDaiCode().getDaiConfigCode() : "";
					final String daiCodeDesc = (regoleView.getDaiCodeId() != null && regoleView.getDaiCodeId().getWeightCodeDescription() != null) ? regoleView.getDaiCodeId().getWeightCodeDescription() : "";
					%>
						<tr>
							<td class="daiAlerttab" align="left" width="10%" nowrap="nowrap"><%=daiGroupDesc%></td>
							<td class="daiAlerttab" align="left" width="65%" nowrap="nowrap">- &nbsp;&nbsp;<span class="regoleAlert" daiType="<%=daiDatiType%>" weightageColor="#F9F9BD" style="text-decoration: underline;"><%=daiCodeDesc%></span></td>
						</tr>
					<%
				}
			%>
		</table>
		<br>
	<%}%>
	
	<%
		if (daiAnagrafeValue == null || "".equals(daiAnagrafeValue)){
			%>
				<table width="100%" border="1" cellspacing="0" cellpadding="5" bordercolor="#CCCCCC" align="center">
					<tr>
						<td class="titolotab" height="35" align="left" width="30%">DAI - Dati ANTIRICICLAGGIO Incompleti</td>
						<td class="titolotab" height="35" align="left" width="60%">&nbsp;</td>
						<td class="titolotab" height="35" align="left" WIDTH="10%"><input type="Button" name="CalcolaDai" value="Aggiorna" style="cursor:hand" onClick="submitMe('CalcolaDai')" class="bottone"> </td>
					</tr>
				</table>
				<br>
			<%
		}
	%>
	
	
<% } else {	
	if ( ExecuterHelper.isExistsSuperiorMotivThanCenst(motivCollection) ) { %>

<table width="100%" border="1" cellspacing="0" cellpadding="5" bordercolor="#CCCCCC" align="center">
	<tr>
		<td class="titolotab" height="35" align="left" width="30%">DAI - Dati ANTIRICICLAGGIO Incompleti</td>
		<td class="titolotab" height="35" align="left" width="60%"><%= daiValue %> </td>
		<td class="titolotab" height="35" align="left" WIDTH="10%">
<% 		if( strSvilpError == null ) { %>
			<input type="Button" name="CalcolaDai" value="Aggiorna" style="cursor:hand"
				onClick="submitMe('CalcolaDai')" class="bottone">
<% 		} %>
		</td>
	</tr>
</table>
<br>
<% } } %>

<%
    if( datiFiscaliError != null || indirizzoPageError != null || documentoError != null ||
       attributiEsterniError != null || intermediariError!= null || recapitiError != null ||
       datiAnagraficiError != null || eventiError != null || datiPrivacyError != null ||
       collegateError != null || codiciSoggettoError != null || segnalatoreError != null || poteriFirmaErrorMessage != null || canalePreferitoError != null)  { %>

<table width="100%" border="1" cellspacing="0" cellpadding="5" bordercolor="#CCCCCC" align="center">
	<tr>
		<td class="titolotab" height="35" align="left">
			<img src="/img/h2o/triangolo.gif" width="25" height="22" hspace="10" align="absmiddle">
				Altri Dati Anagrafici Incompleti
		</td>
	</tr>
</table>
<br>
<% } %>

<% if( datiAnagraficiError != null ) { %>

<table width="100%" border="1" cellspacing="0" cellpadding="5" bordercolor="#CCCCCC" align="center">
	<tr>
		<td class="titolotab" height="35" align="left">
			<img src="/img/h2o/triangolo.gif" width="25" height="22" hspace="10" align="absmiddle">
				<%= datiAnagraficiError %>
		</td>
	</tr>
</table>
<br>
<% } %>


<table class="topH2O" width="100%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
		<table width="100%" bgcolor="white">
			<tr>
				<td class="titolotab" width="30%"><b>Dati Anagrafici</b></td>
<%	if( showModify ) {
    	  if( idForModifica == null) {
%>
				<td class="titolotab" width="70%" align="right">
					<sm:includeIfEventAllowed eventName="DatiAnagraficiModificaNotSec" eventDescription="DatiAnagraficiModifica">
						<input type="Button" name="DatiAnagraficiModifica" value="Modifica" style="cursor:hand"
							onClick="submitMe('DatiAnagraficiModificaNotSec')" class="bottone">
				</sm:includeIfEventAllowed></td>
<%
    	  } else  {

%>
				<td class="titolotab" width="70%" align="right">
					<sm:includeIfEventAllowed eventName="DatiAnagraficiModifica" eventDescription="DatiAnagraficiModifica">
						<input type="Button" name="DatiAnagraficiModifica" value="Modifica" style="cursor:hand"
							onClick="submitMe('DatiAnagraficiModifica')" class="bottone">
					</sm:includeIfEventAllowed>
				</td>
<%
    	}
    } else { %>
				<td class="titolotab" width="70%" align="right">&nbsp;</td>
<%	}	%>
			</tr>
			<tr>
				<td class="VertSxAlta">Nome</td>
				<td class="VertDxAlta DAIPFNomeCognome"><%= datiAnagraficiView.getNome() %></td>
			</tr>
			<tr>
				<td class="VertSxAlta">Cognome</td>
				<td class="VertDxAlta DAIPFNomeCognome"><%= datiAnagraficiView.getCognome() %></td>
			</tr>
			<tr>
				<td class="VertSxAlta">Citt&agrave; di nascita</td>
				<td class="VertDxAlta DAIPFCOB">
<%	if( datiAnagraficiView.getLuogoDiNascitaCitta() != null &&
			datiAnagraficiView.getLuogoDiNascitaCitta().getCommune() != null) { %>
				<%= datiAnagraficiView.getLuogoDiNascitaCitta().getCommune() %>
<%	} %>
				</td>
			</tr>
			<tr>
				<td class="VertSxAlta">Nazione di nascita</td>
				<td class="VertDxAlta DAIPFNOB">
<%	if( datiAnagraficiView.getLuogoDiNascitaNazione() != null ) { %>
				<%= datiAnagraficiView.getLuogoDiNascitaNazione().getNome() %>
<%	} %>
				</td>
			</tr>
			<tr>
				<td class="VertSxAlta">Data di Nascita</td>
				<td class="VertDxAlta DAIPFDOB">
					<%= new DateHandler().formatDate(datiAnagraficiView.getDataDiNascita(),"dd-MM-yyyy") %>
				</td>
			</tr>
		</table>
		</td>
	</tr>
</table>

<br>
<%if( !(( helper.checkForMotiv(motivCollection,"ANTCI") || helper.checkForMotiv(motivCollection,"POSTE")) && ! helper.isExistsuperiorMotivThanAntci(motivCollection))) { %>

<%
if (idForModifica != null ) {
%>
<table class="topH2O" width="100%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
		<table width="100%" bgcolor="white">
			<tr>
				<td class="titolotab" width="30%"><b>Ecofirma</b></td>
				<TD class=titolotab  width="70%" align="right">
					<sm:includeIfEventAllowed eventName="CronistoriaVariazioni" eventDescription="Cronistoria Variazioni">
						<input type="Button" name="CronistoriaVariazioni"
						value="Cronistoria Variazioni" style="cursor:hand" onClick="submitMe('CronistoriaVariazioni')" class="bottone">
					</sm:includeIfEventAllowed>
  				</TD>
			</tr>
			<tr>
				<td class="VertSxAlta">Ecofirma</td>
				<%if(attributiEsterniView != null){ %>
				<%if(attributiEsterniView.getFirmagraf() !=null) {%>
				<td class="VertDxAlta"><%= attributiEsterniView.getFirmagraf().getDescrizione()%> &nbsp;</td>
				<%}else {%>
				<td class="VertDxAlta"><b><font color="red">MANCANTE</font></b>&nbsp;</td>
				<%} %>
				<%} %>
			</tr>
			<tr>
				<td class="VertSxAlta">Data di riferimento</td>
				<td class="VertDxAlta"><font color="grey"><%= attributiEsterniView != null && attributiEsterniView.getFirmadata() != null ? attributiEsterniView.getFirmadata() : ""%> </font>&nbsp;</td>
			</tr>
				</table>
				</td>
				</tr>
				</table>
				<br>
<% } %>
<% } %>
<% if( indirizzoPageError != null ) { %>
<table width="100%" border="1" cellspacing="0" cellpadding="5" bordercolor="#CCCCCC" align="center">
	<tr>
		<td class="titolotab" height="35" align="left">
			<img src="/img/h2o/triangolo.gif" width="25" height="22" hspace="10" align="absmiddle">
				<%= indirizzoPageError %>
		</td>
	</tr>
</table>
<br>
<%
	}
	if( recapitiError != null ) { %>
<table width="100%" border="1" cellspacing="0" cellpadding="5" bordercolor="#CCCCCC" align="center">
	<tr>
		<td class="titolotab" height="35" align="left">
			<img src="/img/h2o/triangolo.gif" width="25" height="22" hspace="10" align="absmiddle">
				<%= recapitiError %>
		</td>
	</tr>
</table>
<br>
<% } if(canalePreferitoError != null) { %> 
<table width="100%" border="1" cellspacing="0" cellpadding="5" bordercolor="#CCCCCC" align="center">
	<tr>
		<td class="titolotab" height="35" align="left">
			<img src="/img/h2o/triangolo.gif" width="25" height="22" hspace="10" align="absmiddle">
				<%= canalePreferitoError %>
		</td>
	</tr>
</table>
<br>
<% } if( datiPrivacyError != null ) {
%>
<table width="100%" border="1" cellspacing="0" cellpadding="5" bordercolor="#CCCCCC" align="center">
	<tr>
		<td class="titolotab" height="35" align="left">
			<img src="/img/h2o/triangolo.gif" width="25" height="22" hspace="10" align="absmiddle">
			<%= datiPrivacyError %>
		</td>
	</tr>
</table>
<br>
<% }%>


<table class="topH2O" width="100%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
		<table width="100%" bgcolor="white">
			<tr>
				<td class="titolotab" width="30%"><b>Residenza</b></td>
<%		
out.print("showModify===="+showModify);
out.print("idForModifica===="+idForModifica);
if( showModify ){ %>
				<td class="titolotab" width="70%" align="right" colspan="3">
				<%if ( idForModifica != null ) { %>
                  		<sm:includeIfEventAllowed eventName="ConfermaModifica" eventDescription="ConfermaModifica">
                  	    	<input type="Button" name="ConfermaModifica" value="ConfermaModifica" style="cursor:hand" onClick="submitMe('ConfermaModifica')" clasS="bottone">
                  	    </sm:includeIfEventAllowed>&nbsp;&nbsp;&nbsp;
				<%}%>
					<input type="Button" name="IndirizziRecapitiPrivacyModifica" value="Modifica"
						style="cursor:hand" onClick="submitMe('IndirizziRecapitiPrivacyModifica')"
						class="bottone">
				</td>
<%		} else { %>
				<td class="titolotab" width="70%" align="right">&nbsp;</td>
<%		} %>
			</tr>
<%
     String indirizzo = "";
     String strCap = "";
     String strCitta = "";
     String strProvincia = "";
     String strNazione = "";
     String strEdificio = "";
     String strPresso ="";
     if ( indirizzoResidenzaView != null ) {
       indirizzo = indirizzoResidenzaView.getIndirizzo();
       if( indirizzoResidenzaView.getCap()!= null )
         strCap = indirizzoResidenzaView.getCap().getCap();
       else
          strCap = indirizzoResidenzaView.getCapCode();
       if( indirizzoResidenzaView.getCitta() != null )
         strCitta = indirizzoResidenzaView.getCitta().getCommune();
       else
          strCitta = indirizzoResidenzaView.getCittaCommune();
       if( indirizzoResidenzaView.getProvincia()!= null )
         strProvincia = indirizzoResidenzaView.getProvincia().getSigla();
       else
          strProvincia = indirizzoResidenzaView.getProvinciaSigla();
       if( indirizzoResidenzaView.getNazione() != null )
         strNazione = indirizzoResidenzaView.getNazione().getNome();
       if ( indirizzoResidenzaView.getEdificio() != null ) {
    	   strEdificio = indirizzoResidenzaView.getEdificio();
       } 
       if ( indirizzoResidenzaView.getPresso() != null ) {
    	   strPresso = indirizzoResidenzaView.getPresso();
       }
     }
%>

			<tr>
				<td class="VertSxAlta">C/O(presso)</td>
				<td class="VertDxAlta "><%= strPresso %>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta">Nazione</td>
				<td class="VertDxAlta DAIPFIRENAZ"><%= strNazione %>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta">CAP</td>
				<td class="VertDxAlta"><%= strCap %>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta">Provincia</td>
				<td class="VertDxAlta DAIPFIREPRO DAIPFIRECPR"><%= strProvincia %>&nbsp;</td>
			</tr>
			
			<tr>
				<td class="VertSxAlta">Citt&agrave;</td>
				<td class="VertDxAlta DAIPFIRECIT DAIPFIRECPR"><%= strCitta %>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta">Indirizzo</td>
				<td class="VertDxAlta DAIPFIREIND"><%= indirizzo %>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta">Edificio</td>
				<td class="VertDxAlta "><%= strEdificio %>&nbsp;</td>
			</tr>
<%
     if( !((helper.checkForMotiv(motivCollection,"ANTCI") || helper.checkForMotiv(motivCollection,"POSTE")) && !helper.isExistsuperiorMotivThanAntci(motivCollection))) { %>
			<tr class="interna">
				<td class="titolotab"><b>Domicilio</b></td>
<%		if( showModify ){ %>
				<td class="titolotab" width="70%" align="right">
					<input type="Button" name="IndirizziRecapitiPrivacyModifica" value="Modifica"
						style="cursor:hand" onClick="submitMe('IndirizziRecapitiPrivacyModifica')"
						class="bottone">

				</td>
<%		} else { %>
				<td class="titolotab" width="70%" align="right">&nbsp;</td>
<%		} %>
			</tr>
<%
        indirizzo = "";
        strCap = "";
        strCitta = "";
        strProvincia = "";
        strNazione = "";
        strEdificio = "";
        strPresso = "";
        if ( indirizzoDomicilioView != null ) {
          indirizzo = indirizzoDomicilioView.getIndirizzo();
          if( indirizzoDomicilioView.getCap()!= null )
            strCap = indirizzoDomicilioView.getCap().getCap();
          else
             strCap = indirizzoDomicilioView.getCapCode();
          if( indirizzoDomicilioView.getCitta() != null )
            strCitta = indirizzoDomicilioView.getCitta().getCommune();
          else
            strCitta = indirizzoDomicilioView.getCittaCommune();
          if( indirizzoDomicilioView.getProvincia()!= null )
            strProvincia = indirizzoDomicilioView.getProvincia().getSigla();
          else
            strProvincia = indirizzoDomicilioView.getProvinciaSigla();
          if( indirizzoDomicilioView.getNazione() != null )
            strNazione = indirizzoDomicilioView.getNazione().getNome();
          if ( indirizzoDomicilioView.getEdificio() != null ) {
       	   strEdificio = indirizzoDomicilioView.getEdificio();
          }
          if ( indirizzoDomicilioView.getPresso() != null ) {
          	   strPresso = indirizzoDomicilioView.getPresso();
             }
        }
%>
			<tr>
				<td class="VertSxAlta">C/O(presso)</td>
				<td class="VertDxAlta "><%= strPresso %>&nbsp;</td>
			</tr>
			<tr class="interna">
				<td class="VertSxAlta">Nazione</td>
				<td class="VertDxAlta DAIIDONAZ"><%= strNazione %>&nbsp;</td>
			</tr>
			<tr class="interna">
				<td class="VertSxAlta">CAP</td>
				<td class="VertDxAlta"><%= strCap %>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta">Provincia</td>
				<td class="VertDxAlta DAIIDOPRO DAIIDOCPR"><%= strProvincia %>&nbsp;</td>
			</tr>
			<tr class="interna">
				<td class="VertSxAlta">Citt&agrave;</td>
				<td class="VertDxAlta DAIIDOCIT DAIIDOCPR"><%= strCitta %>&nbsp;</td>
			</tr>
			<tr class="interna">
				<td class="VertSxAlta">Indirizzo</td>
				<td class="VertDxAlta DAIIDOIND"><%= indirizzo %>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta">Edificio</td>
				<td class="VertDxAlta "><%= strEdificio %>&nbsp;</td>
			</tr>
<% 	} 	%>
</table>
<% if(!((helper.checkForMotiv(motivCollection,"ANTCI") || helper.checkForMotiv(motivCollection,"POSTE")) && !helper.isExistsuperiorMotivThanAntci(motivCollection))) { %>
		<table width="100%" bgColor="white">
			<tr>
				<td  class="titolotab"><b>Dati Recapito</b></td>
<%		if( showModify ){ %>
				<td class="titolotab" width="70%" align="right" colspan="3">
				<%if ( idForModifica != null ) { %>
                  		<sm:includeIfEventAllowed eventName="ManageRecapiti" eventDescription="Modifica solo i Recapiti">
                  	    	<input type="Button" name="ManageRecapiti" value="Modifica solo i Recapiti" style="cursor:hand" onClick="submitMe('ManageRecapiti')" clasS="bottone">
                  	    </sm:includeIfEventAllowed>&nbsp;&nbsp;&nbsp;
				<%}%>
					<input type="Button" name="IndirizziRecapitiPrivacyModifica" value="Modifica"
						style="cursor:hand" onClick="submitMe('IndirizziRecapitiPrivacyModifica')"
						class="bottone">
				</td>
<%		} else { %>
				<td class="titolotab" width="70%" align="right">&nbsp;</td>
<%		} %>
			</tr>
			<tr>
				<td class="VertSxAlta" width="30%">Tipo Recapito</td>
				<TD class="VertSxAlta" width="20%">Prefisso</TD>
				<td class="VertSxAlta" width="20%">Numero/e-mail ecc.</td>
				<td class="VertSxAlta" width="30%">Note</td>
			</tr>
<%
         if( recapitiCollection != null ) {
            Iterator iterator = recapitiCollection.iterator();
            size = recapitiCollection.size();
            for( int i=0; i<size; i++ ) {
              recapitiView=(SoggettoRecapitiView)iterator.next();
              if( recapitiView.getTipoRecapiti()!= null ) {
                 strDescrizione = recapitiView.getTipoRecapiti().getDescrizione();
              }
%>
			<tr>
				<td class="VertDxAlta"><%= strDescrizione %>&nbsp;</td>
				<TD class="VertDxAlta" ><%=recapitiView.getPrefissoCode()%>&nbsp;</TD>
				<td class="VertDxAlta"><%=recapitiView.getValoreRecapiti()%>&nbsp;</td>
				<td class="VertDxAlta"><%=recapitiView.getRiferimento()%>&nbsp;</td>
			</tr>
<% 		  }
	}
%>		
		<tr>
				<td class="VertSxAlta">Canale di comunicazione preferito</td>
				<td class="VertDxAlta" colspan="3"><%=canaleDisplayVal%></td>				
			</tr>    
			<tr>
				<td class="VertSxAlta">Canale pi&ugrave; utilizzato (op. dispositive)</td>
				<td class="VertDxAlta" colspan="3"><%=canaleUtilizzatoView != null && canaleUtilizzatoView.getCanaleUtilizzato() != null ? canaleUtilizzatoView.getCanaleUtilizzato() : ""%></td>
			</tr>
		</table>

<table width="100%" BGCOLOR="white">
	<tr>
		<td class="titolotab" width="30%"><b>Dati Privacy</b></td>
<% if( showModify ) { %>
		<td class="titolotab" width="70%" colspan="2" align="right">
<%
		if(((Boolean)view.getOutputAttribute("VARIA")).booleanValue() &&
				(((Boolean)view.getOutputAttribute("PRIVACY_MODIFIED"))).booleanValue()) {
%>
				<!--  <input type="Button" name="StampePrivacyPrint" value="StampePrivacy" style="cursor:hand" onClick="submitMe('StampePrivacyPrint')" class="bottone"> -->
<% 		}  %>
  					<input type="Button" name="IndirizziRecapitiPrivacyModifica" value="Modifica" style="cursor:hand" onClick="submitMe('IndirizziRecapitiPrivacyModifica')" class="bottone">
		</td>
<%  	} else { %>
		<td class="titolotab" align="right">&nbsp;</td>
<%  	}   %>
	</tr>

			<!--     		//////////   Five level	///////	-->

<%
    if ((datiPrivacyPFView != null) && (datiPrivacyPFView.getLivello1() != null) && (datiPrivacyPFFiveLevelView == null) )  {
	     	String level[] = new String[6];
	     	for (int i=0;i<6;i++)
	     		level[i]="";

	        level[0] = datiPrivacyPFView.getLivello1();
	        level[1] = datiPrivacyPFView.getLivello2();
	        level[2] = datiPrivacyPFView.getLivello3();
	        level[3] = datiPrivacyPFView.getLivello4();
	        level[4] = datiPrivacyPFView.getLivello5();
	        level[5] = datiPrivacyPFView.getLivello6();

	      	String livellomsg[] = new String[6];
	    	livellomsg[0] = "Consenso alla comunicazione e al trattamento dei dati personali per l'esecuzione delle operazioni e dei servizi bancari diversi da quelli indicati nel riquadro B dell'informativa.";
	   		livellomsg[1] = "Consenso alla comunicazione, da parte della banca, dei dati a società di rilevazione della qualità dei servizi erogati.";
	      	livellomsg[2] = "Consenso al trattamento, da parte della banca, dei dati a fini di informazioni commerciali, ricerche di mercato, offerte dirette di prodotti o servizi del gruppo. ";
	    	livellomsg[3] = "Consenso al trattamento, da parte della banca, dei dati a fini di informazioni commerciali, ricerche di mercato, offerte dirette di prodotti o servizi di società terze. ";
	   		livellomsg[4] = "Consenso alla comunicazione, da parte della banca, dei dati a società terze a fini di informazioni commerciali, ricerche di mercato, offerte dirette di loro prodotti.";
	   		livellomsg[5] = "Consenso al trattamento di dati sensibili.";

	         String sixLevelStatus = "";
	         for (int i=0; i<6;i++){
	         	 sixLevelStatus = "";

%>
		<TR>
			<TD class="VertSxAlta" width="95%" colspan="2"><B>Livello <%=i+1%> </B><%=livellomsg[i]%></TD>
			<TD class="VertDxAlta" width="5%" align="center">
<%
				if( level[i]!= null && "true".equals(level[i]) ) {
					sixLevelStatus = "Si";
				} else if( level[i]!= null && "false".equals(level[i]) ) {
					sixLevelStatus = "No" ;
				}
%>
			<%= sixLevelStatus %>
			</TD>
		</TR>
<%	  	   }
	} else {
		showPrivacyLogData = true;
		String levelFive[] = new String[6];
       	for (int i=0;i<6;i++)
       		levelFive[i]="";
		if( datiPrivacyPFFiveLevelView != null ) {
		    levelFive[0] = datiPrivacyPFFiveLevelView.getLivello1();
            levelFive[1] = datiPrivacyPFFiveLevelView.getLivello2();
            levelFive[2] = datiPrivacyPFFiveLevelView.getLivello3();
            levelFive[3] = datiPrivacyPFFiveLevelView.getLivello4();
            levelFive[4] = datiPrivacyPFFiveLevelView.getLivello5();
            levelFive[5] = datiPrivacyPFFiveLevelView.getProfil();
		}
		boolean showProfilLabel = true;
		String fiveLeveldata[] = new String[5];
		for (int i = 0; i < 5; i++)
			fiveLeveldata[i] = "";
		if(profilPrivacyApplicable && privFivelevelDisplay != null && (levelFive[5] == null || "".equals(levelFive[5]))) {
			fiveLeveldata[0] =  privFivelevelDisplay.getLivello1();
			fiveLeveldata[1] =  privFivelevelDisplay.getLivello2();
			fiveLeveldata[2] =  privFivelevelDisplay.getLivello3();
			fiveLeveldata[3] =  privFivelevelDisplay.getLivello4();
			fiveLeveldata[4] =  privFivelevelDisplay.getLivello5();
			showProfilLabel = false;
		}
        String livelloFiveMsg[] = new String[6];
   	    livelloFiveMsg[0] = "Consenso alla comunicazione e al trattamento dei <b>dati personali</b> per l'esecuzione delle operazioni e dei servizi bancari diversi da quelli nell'informativa per i quali non è necessario richiedere il consenso all'interessato";
       	livelloFiveMsg[1] = "Consenso alla conservazione della <b>cronistoria</b> delle attività precontrattuali";
        livelloFiveMsg[2] = "Consenso al trattamento dei dati da parte della banca per promozione/vendita di prodotti/servizi (anche di terzi), rilevazione del grado di soddisfazione della clientela, ricerche di mercato";
   	    livelloFiveMsg[3] = "Consenso alla comunicazione dei dati a soggetti terzi che svolgono per conto della banca attività di promozione/vendita di prodotti/servizi, rilevazione del grado di soddisfazione della clientela, ricerche di mercato";
       	livelloFiveMsg[4] = "Consenso al trattamento di <b>dati sensibili</b> al fine di consentire alla Banca l'esecuzione di disposizioni impartite dal cliente stesso che contengano dati \"sensibili\" (es.: ordini di pagamento dalla cui causale descrittiva e/o beneficiario siano desumibili dati relativi all'iscrizione a sindacati, partiti politici o altre associazioni, oppure allo stato di salute)";
       	
       	int[] orderOfLevel = new int[] {0,4,1,2,3};
       	
       	if(profilPrivacyApplicable) {
       		livelloFiveMsg[5] =  "Consenso al trattamento dei dati per finalità di <b>profilazione</b>";
       		orderOfLevel = new int[] {0,4,1,2,3,5};
       	}
       	
       	
       	if(showProfilLabel) {
           	String fiveLevelStatus = "";
           	for (int i : orderOfLevel) {
              	 fiveLevelStatus = "";
   			 %>
    			<TR>
    				<TD class="VertSxAlta" width="95%" colspan="2"><%=livelloFiveMsg[i]%> </TD>
    				<TD class="VertDxAlta" width="5%" align="center">
    			<%if( levelFive[i]!= null && "true".equals(levelFive[i]) ) {
    					fiveLevelStatus = "Si";
    			} else if( levelFive[i]!= null && "false".equals(levelFive[i]) ){
    					fiveLevelStatus = "No" ;
    			} %> 	
    			<%= fiveLevelStatus %>
    				</TD>
    			</TR>
    	 <%  }
       	} else {
       		String fiveLevelStatus = "";
       		for (int i = 0; i < 5; i++) {
             	 fiveLevelStatus = "";
  			 %>
   			<TR>
   				<TD class="VertSxAlta" width="95%" colspan="2"><B><%=i + 1%>° consenso - </B> <%=livelloFiveMsg[i]%> </TD>
   				<TD class="VertDxAlta" width="5%" align="center">
   			<%if( fiveLeveldata[i]!= null && "true".equals(fiveLeveldata[i]) ) {
   					fiveLevelStatus = "Si";
   			} else if( fiveLeveldata[i]!= null && "false".equals(fiveLeveldata[i]) ){
   					fiveLevelStatus = "No" ;
   			} %> 	
   			<%= fiveLevelStatus %>
   				</TD>
   			</TR>
   	 <%  }
       		
       	}
	 }
%>
	</table>
<%  } %>
<%
		if(showPrivacyLogData && privacyLogView != null) {
			String dateOfOperation = privacyLogView.getDateOfOperation() != null ? new DateHandler().formatDate(privacyLogView.getDateOfOperation() ,"dd-MM-yyyy") : "";
	%>
		<table bgcolor="white" width="100%">
			<tr>
				<TD class=VertSxAlta width="40%"><b>Ultima variazione</b></TD>
				<TD class=VertDxAlta width="30%" align=center><%=privacyLogView.getCodiciDipendente() != null ? privacyLogView.getCodiciDipendente() : ""%></TD>
				<TD class=VertDxAlta width="30%" align=center><%=dateOfOperation %></TD>
			</tr>
		</table>
	<% } %>
	  </td>
	</tr>
</table>
<br>


<% if( attributiEsterniError != null ) { %>
<table width="100%" border="1" cellspacing="0" cellpadding="5" bordercolor="#CCCCCC" align="center">
	<tr>
		<td class="titolotab" height="35" align="left">
			<img src="/img/h2o/triangolo.gif" width="25" height="22" hspace="10" align="absmiddle">
				<%= attributiEsterniError %>
		</td>
	</tr>
</table>
<br>
<% }
   if(datiFiscaliError != null) {
%>
<table width="100%" border="1" cellspacing="0" cellpadding="5" bordercolor="#CCCCCC" align="center">
	<tr>
		<td class="titolotab" height="35" align="left">
			<img src="/img/h2o/triangolo.gif" width="25" height="22" hspace="10" align="absmiddle">
				<%= datiFiscaliError %>
		</td>
	</tr>
</table>
<br>
<% } if (residenzaFisWarning != null) { %>
<table width="100%" border="1" cellspacing="0" cellpadding="5" bordercolor="#CCCCCC" align="center">
	<tr>
		<td class="titolotab" height="35" align="left">
			<img src="/img/h2o/news.gif" width="25" height="22" hspace="10" align="absmiddle">
				<%= residenzaFisWarning %>
		</td>
	</tr>
</table>
<br>
<% }if(documentoError != null) { %>
<table width="100%" border="1" cellspacing="0" cellpadding="5" bordercolor="#CCCCCC" align="center">
	<tr>
		<td class="titolotab" height="35" align="left">
			<img src="/img/h2o/triangolo.gif" width="25" height="22" hspace="10" align="absmiddle">
				<%= documentoError %>
		</td>
	</tr>
</table>
<br>
<% } %>

<table class="topH2O" width="100%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
		<table width="100%" bgcolor="white">
			<tr>
				<td class="titolotab" width="45%"><b>Attributi</b></td>
<%	if( showModify ) { %>
				<td class="titolotab" width="55%" align="right">
					<input type="Button" name="AttributiFiscaliDocumentiModifica" value="Modifica"
						style="cursor:hand" onClick="submitMe('AttributiFiscaliDocumentiModifica')"
						class="bottone">
				</td>
<%	} else {	%>
				<td class="titolotab" width="55%" align="right">&nbsp;</td>
<%	}	%>
			</tr>
<% if(!((helper.checkForMotiv(motivCollection,"ANTCI") || helper.checkForMotiv(motivCollection,"POSTE")) && !helper.isExistsuperiorMotivThanAntci(motivCollection))) { %>
			<tr>
				<td class="VertSxAlta">Titolo 1</td>
<%
        strDescrizione = "";
		if( attributiEsterniView != null && attributiEsterniView.getTitolo1()!= null ) {
		  strDescrizione = attributiEsterniView.getTitolo1().getDescrizione();
		}
%>
				<td class="VertDxAlta"><%= strDescrizione %>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta">Titolo 2</td>
<%
      	strDescrizione = "";
		if( attributiEsterniView != null && attributiEsterniView.getTitolo2()!= null ) {
		  strDescrizione = attributiEsterniView.getTitolo2().getDescrizione();
		}
%>

				<td class="VertDxAlta"><%= strDescrizione %>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta">Titolo Studio</td>
<%
      	strDescrizione = "";
		if( attributiEsterniView != null && attributiEsterniView.getTds()!= null ) {
		  strDescrizione = attributiEsterniView.getTds().getDescrizione();
		}
%>

				<td class="VertDxAlta"><%= strDescrizione %>&nbsp;</td>
			</tr>
<% } %>
			<tr>
				<td class="VertSxAlta">Sesso</td>
<%
    strDescrizione = "";
	if( attributiEsterniView != null && attributiEsterniView.getSesso()!= null ) {
	  strDescrizione = attributiEsterniView.getSesso().getDescrizione();
	}
%>
				<td class="VertDxAlta"><%= strDescrizione %>&nbsp;</td>
			</tr>

<% if(!((helper.checkForMotiv(motivCollection,"ANTCI") || helper.checkForMotiv(motivCollection,"POSTE")) && !helper.isExistsuperiorMotivThanAntci(motivCollection))) { %>
			<tr>
				<td class="VertSxAlta">Stato civile</td>
<%
      	strDescrizione = "";
		if( attributiEsterniView != null && attributiEsterniView.getStatoCivile()!= null ) {
		  strDescrizione = attributiEsterniView.getStatoCivile().getDescrizione();
		}
%>

				<td class="VertDxAlta"><%= strDescrizione %>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta">Lingua</td>
<%
        strDescrizione = "";
		if(attributiEsterniView != null && attributiEsterniView.getLingua()!= null) {
		  strDescrizione = attributiEsterniView.getLingua().getDescrizione();
		}
%>
				<td class="VertDxAlta"><%= strDescrizione %>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta">Professione</td>
<%
        strDescrizione = "";
		if( attributiEsterniView != null && attributiEsterniView.getProfessione()!= null) {
		  strDescrizione = attributiEsterniView.getProfessione().getDescrizione();
		}
%>
				<td class="VertDxAlta DAIPFAEPRO"><%= strDescrizione %>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta">Settore Attività</td>
<%
        strDescrizione = "";
		if( attributiEsterniView != null && attributiEsterniView.getSettorediattivita()!=null) {
		  strDescrizione = attributiEsterniView.getSettorediattivita().getSettoreAttivitaDescription();
		}
		
%>
				<td class="VertDxAlta"><%= strDescrizione %>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta">Tipo di Attività Economica(T.A.E)</td>
<%
        strDescrizione = "";
		if( attributiEsterniView != null && attributiEsterniView.getTae()!=null) {
		  strDescrizione = attributiEsterniView.getTae().getTaeDesc();
		}
%>
				<td class="VertDxAlta DAIPFAETAE"><%= strDescrizione %>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta">Settore Commerciale</td>
			<% if(attributiEsterniView.getSettorecommerciale() !=null){
                    	  settoreCommerciale =attributiEsterniView.getSettorecommerciale().getCausale().concat("-").concat(attributiEsterniView.getSettorecommerciale().getDescrizione());
                      }%>	
				<td class="VertDxAlta"><%= settoreCommerciale %>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta">Albo professionale</td>
<%
        strDescrizione = "";
		if( attributiEsterniView != null && attributiEsterniView.getAlbo_prof()!= null) {
		  strDescrizione = attributiEsterniView.getAlbo_prof().getAlboDesc();
		}
%>
				<td class="VertDxAlta"><%= strDescrizione %>&nbsp;</td>
			</tr>

			<tr>
				<td class="VertSxAlta">Numero di iscrizione all' albo</td>
<%
        strDescrizione = "";
		if( attributiEsterniView != null && attributiEsterniView.getNumero_di_albo()!=null) {
		  strDescrizione = attributiEsterniView.getNumero_di_albo();
		}
%>
				<td class="VertDxAlta"><%= strDescrizione %>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta">Ulteriori annotazioni</td>
<%
        strDescrizione = "";
		if( attributiEsterniView != null && attributiEsterniView.getUlteriori_annotazioni()!= null) {
		  strDescrizione = attributiEsterniView.getUlteriori_annotazioni();
		}
%>
				<td class="VertDxAlta"><%= strDescrizione %>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta">Soggetto apicale</td>
				<td class="VertDxAlta"><%= attributiEsterniView != null && attributiEsterniView.getSoggetto_apicale() != null && attributiEsterniView.getSoggetto_apicale() ?
											"Si" : "No"%>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta">Regime patrimoniale</td>
<%
        strDescrizione = "";
		if( attributiEsterniView != null && attributiEsterniView.getRegimePatrimoniale()!= null ) {
		  strDescrizione = attributiEsterniView.getRegimePatrimoniale().getDescrizione();
		}
%>
				<td class="VertDxAlta"><%= strDescrizione %>&nbsp;</td>
			</tr>

<% } %>

			<tr>
				<td class="VertSxAlta">Cittadinanza</td>
<%
            strDescrizione = "";
            if( attributiEsterniView != null && attributiEsterniView.getCittadinanza()!= null ) {
              strDescrizione = attributiEsterniView.getCittadinanza().getNome();
            }
%>
				<td class="VertDxAlta DAIPFAECIT"><%= strDescrizione %>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta">Seconda Cittadinanza</td>
<%
            strDescrizione = "";
            if( attributiEsterniView != null && attributiEsterniView.getSecondaCittadinanza()!= null ) {
              strDescrizione = attributiEsterniView.getSecondaCittadinanza().getNome();
            }
%>
				<td class="VertDxAlta"><%= strDescrizione %>&nbsp;</td>
			</tr>
<% if(!((helper.checkForMotiv(motivCollection,"ANTCI") || helper.checkForMotiv(motivCollection,"POSTE")) && !helper.isExistsuperiorMotivThanAntci(motivCollection))) { %>
			<tr>
				<td class="VertSxAlta">Settore</td>
				<td class="VertDxAlta"><%= attributiEsterniView != null &&
        						   attributiEsterniView.getSettore() != null ?
        						   attributiEsterniView.getSettore() : ""%>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta">Ramo</td>
				<td class="VertDxAlta"><%= attributiEsterniView != null &&
        						   attributiEsterniView.getRamo() != null ?
   								   attributiEsterniView.getRamo() : ""%>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta"><b>Autorizzato allo sconfino</b></td>
<%
             if (attributiEsterniView != null) {
                 if("true".equals(attributiEsterniView.getSconf()))
                     strDescrizione = "Si";
                 else if("false".equals(attributiEsterniView.getSconf()))
                     strDescrizione = "No";
                 else
                     strDescrizione = "Sotto Osservazione";
             }
%>

				<td class="VertDxAlta"><%= strDescrizione %>&nbsp;</td>
			</tr>
			<% } %>
			<tr>
				<td class="VertSxAlta">Parente promotore BPA</td>
				<td class="VertDxAlta"><%= attributiEsterniView != null &&
									"true".equals(attributiEsterniView.getParpr()) ?
											"Si" : "No"%>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta">Promotore altre banche</td>
				<td class="VertDxAlta"><%= attributiEsterniView != null &&
									"true".equals(attributiEsterniView.getAtrpr()) ?
											"Si" : "No"%>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta">Soggetto idoneo potenziale azionista BSH - BSE</td>
				<td class="VertDxAlta"><%= attributiEsterniView != null && attributiEsterniView.getSBJ_ELIGIBLE() != null && attributiEsterniView.getSBJ_ELIGIBLE() ?
											"Si" : "No"%>&nbsp;</td>
			</tr>
<% 
			if(idForModifica != null) {
%>				
			<tr>
				<td class="VertSxAlta">Soggetto azionista Banca Sella</td>
				<td class="VertDxAlta"><%= attributiEsterniView != null && "true".equals(attributiEsterniView.getSocioBSE()) ?
						"Si" : "No"%>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta">Soggetto azionista Banca Sella Holding</td>
				<td class="VertDxAlta"><%= attributiEsterniView != null && "true".equals(attributiEsterniView.getSocioSHB()) ?
						"Si" : "No"%>&nbsp;</td>
			</tr>
<% 			
			}
%>
</table>
<table width="100%" bgcolor="white">
			<tr>
				<td class="titolotab"><b>Dati Fiscali</b></td>
<% if( showModify ) { %>
				<td class="titolotab" width="55%" align="right"><input type="Button"
					name="AttributiFiscaliDocumentiModifica" value="Modifica"
					style="cursor:hand"
					onClick="submitMe('AttributiFiscaliDocumentiModifica')"
					class="bottone"></td>
				<%} else {%>
				<td class="titolotab" width="55%" align="right">&nbsp;</td>
				<%}%>
			</tr>
			<%
            String codiceFiscale = "";
            String partitaIva = "";
            String residenzaValutaria = "";
            String residenzaFiscale = "";
            String indicatoreRV = "No";
            //String indicatoreA95 = "No";
            String indicatoreA96 = "No";
            String indicatoreA97 = "No";
            String w8 = "No";
            String w8i = "No";
            String w9 = "No";
            String codiceFiscaleEstero = "";
            //String applicazioneIVA = "";
            String regimeDeiMinimi = "";
            String regimeDataAttivazione = "";
            String regimeDataRevoca = "";
            String regimeDataScadenza = "";
            String fatcaSoggettoUSA = "";
            String fatcaStatus = "";
            String presenzaDiIndizi = "";
            String numSic = "";
            String residenzaFiscale2 = "";
            String residenzaFiscale3 = "";
            String codiceFiscaleEstero2 = "";
            String codiceFiscaleEstero3 = "";
            boolean isAlterResidAllowed=false;

            if(datiFiscaliView != null)
            {
              codiceFiscale = datiFiscaliView.getCodiceFiscali();
              partitaIva = datiFiscaliView.getPartitaIva();
              if(datiFiscaliView.getRzVal()!= null)
                residenzaValutaria = datiFiscaliView.getRzVal().getNome();
              if(datiFiscaliView.getCertRV() != null && datiFiscaliView.getCertRV().booleanValue())
                indicatoreRV = "Si";
              if(datiFiscaliView.getResidenteFiscali()!= null)
                residenzaFiscale = datiFiscaliView.getResidenteFiscali().getNome();
              if(datiFiscaliView.getIndicatoreA97().booleanValue())
                indicatoreA97 = "Si";
              if(datiFiscaliView.getIndicatoreA96().booleanValue())
                indicatoreA96 = "Si";
/*
              if(datiFiscaliView.getIndicatoreA95().booleanValue())
                indicatoreA95 = "Si";
*/
              if(datiFiscaliView.getW8() != null && datiFiscaliView.getW8().booleanValue())
                w8 = "Si";
              if(datiFiscaliView.getW8i() != null && datiFiscaliView.getW8i().booleanValue())
                w8i = "Si";
              if(datiFiscaliView.getW9() != null && datiFiscaliView.getW9().booleanValue()) {
                w9 = "Si";
              }
              if(("".equals(isUsOriginDatiIndirzzo) || "N".equals(isUsOriginDatiIndirzzo)) && ("".equals(isUsOriginAll) || "N".equals(isUsOriginAll)) && "N".equals(isUsOriginCollegate)){
              	w9 = "No";
              }
              codiceFiscaleEstero = datiFiscaliView.getCdEst();
              regimeDeiMinimi = datiFiscaliView.getRegimeDeiMinimi() != null && datiFiscaliView.getRegimeDeiMinimi() ? "Si" : "No";
              final DateHandler dateHandler = new DateHandler();
              if(datiFiscaliView.getRegimeDataAttivazione() != null){
            	  regimeDataAttivazione =dateHandler.formatDate(datiFiscaliView.getRegimeDataAttivazione(),"dd/MM/yyyy");
              }
              if(datiFiscaliView.getRegimeDataRevoca() != null){
            	  regimeDataRevoca =dateHandler.formatDate(datiFiscaliView.getRegimeDataRevoca(),"dd/MM/yyyy");
              }
              if(datiFiscaliView.getRegimeDataScadenza() != null){
            	  regimeDataScadenza =dateHandler.formatDate(datiFiscaliView.getRegimeDataScadenza(),"dd/MM/yyyy");
              }
              if(datiFiscaliView.getResidenteFiscali2()!= null){
                  residenzaFiscale2 = datiFiscaliView.getResidenteFiscali2().getNome();
              }
              if(datiFiscaliView.getResidenteFiscali3()!= null){
                  residenzaFiscale3 = datiFiscaliView.getResidenteFiscali3().getNome();
              }
              if(datiFiscaliView.getCdEst2()!= null){
            	  codiceFiscaleEstero2=datiFiscaliView.getCdEst2();
              }
 			 if(datiFiscaliView.getCdEst3()!= null){
 				codiceFiscaleEstero3=datiFiscaliView.getCdEst3();
              }
              final String fatcaSoggettoUSACausale = datiFiscaliView.getFatca_soggetto_usa() != null ? datiFiscaliView.getFatca_soggetto_usa().getCausale() : "";
              final String fatcaSoggettoUSADesc = datiFiscaliView.getFatca_soggetto_usa() != null ? datiFiscaliView.getFatca_soggetto_usa().getDescrizione() : "";
              final String fatcaStatusCausale = datiFiscaliView.getFatca_status() != null ? datiFiscaliView.getFatca_status().getCausale() : "";
              final String fatcaStatusDesc = datiFiscaliView.getFatca_status() != null ? datiFiscaliView.getFatca_status().getDescrizione() : "";
              fatcaSoggettoUSA = !"".equals(fatcaSoggettoUSACausale) ? fatcaSoggettoUSACausale.concat("-").concat(fatcaSoggettoUSADesc) : "Non Calcolato";
              fatcaStatus = !"".equals(fatcaStatusCausale) ? fatcaStatusCausale.concat("-").concat(fatcaStatusDesc) : "Non Calcolato";
              presenzaDiIndizi = datiFiscaliView.getPresenza_indizi() != null ? datiFiscaliView.getPresenza_indizi() : "Non Calcolato";
              numSic = datiFiscaliView.getNumSic() != null ? datiFiscaliView.getNumSic() : "";
              presenzaDiIndizi = ("Y".equals(isUsOriginDatiIndirzzo) || "Y".equals(isUsOriginAll)) ? "Si" : (!"Non Calcolato".equals(presenzaDiIndizi)) ? "No" : presenzaDiIndizi;
              isAlterResidAllowed = ((Boolean)view.getOutputAttribute("IS_CONFIG_ALLOWED")).booleanValue();
           }
        %>
			<tr>
				<td class="VertSxAlta" width="45%">Codice Fiscale (OBBLIGATORIO anche per residenti estero)</td>
				<td class="VertDxAlta DAIPFCF" width="55%"><%= codiceFiscale %> &nbsp;</td>
			</tr>
			<% if(!((helper.checkForMotiv(motivCollection,"ANTCI") || helper.checkForMotiv(motivCollection,"POSTE")) && !helper.isExistsuperiorMotivThanAntci(motivCollection))) { %>
			<tr>
				<td class="VertSxAlta">Partita Iva</td>
				<td class="VertDxAlta"><%= partitaIva %>&nbsp;</td>
			</tr>
			<tr>
					<td class="VertSxAlta">Applicazione IVA</td>
					<td class="VertDxAlta"><%=apivacausale != null && apivadescrip != null ?  apivacausale+"-"+apivadescrip: ""%></td>
				</tr>
				
			<tr>
				<td class="VertSxAlta">Residenza Valutaria</td>
				<td class="VertDxAlta"><%= residenzaValutaria %>&nbsp;</td>
			</tr>
			
			<tr>
				<td class="VertSxAlta">Cert. di Attestazione di Res. Valutaria in
				Stato Estero</td>
				<td class="VertDxAlta"><%= indicatoreRV %>&nbsp;</td>
			</tr>
			<%} %>
			<% if(!(( helper.checkForMotiv(motivCollection,"POSTE")) && !helper.isExistsuperiorMotivThanAntci(motivCollection))) { %>
			<tr>
				<td class="VertSxAlta">Residenza Fiscale</td>
				<td class="VertDxAlta"><%= residenzaFiscale %>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta" width="60%">Codice Identificativo Fiscale Estero &nbsp;<a href="/Anagrafe/include/NazioneList.html" target="_blank">(elenco nazioni)</a>
				<br>E' richiesto per soggetti con Res. Fiscale all'Estero. E' utilizzato nella dichiarazione dei sostituti d'imposta.
				</td>
				<td class="VertDxAlta" colspan="2" width="40%"><%= codiceFiscaleEstero %>&nbsp;</td>
			</tr>
			<%if(isAlterResidAllowed){ %>
			<tr>
				<td class="VertSxAlta">Seconda Residenza Fiscale</td>
				<td class="VertDxAlta"><%= residenzaFiscale2 %>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta" width="60%">Secondo Codice Identificativo Fiscale Estero
				</td>
				<td class="VertDxAlta" colspan="2" width="40%"><%= codiceFiscaleEstero2 %>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta">Terza residenza fiscale</td>
				<td class="VertDxAlta"><%= residenzaFiscale3 %>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta" width="60%">Terzo Codice Identificativo Fiscale Estero
				</td>
				<td class="VertDxAlta" colspan="2" width="40%"><%= codiceFiscaleEstero3 %>&nbsp;</td>
			</tr>
			<% } 
			}%>
		</table>
		<% if(!((helper.checkForMotiv(motivCollection,"ANTCI") || helper.checkForMotiv(motivCollection,"POSTE")) && !helper.isExistsuperiorMotivThanAntci(motivCollection))) { %>
		<table width="100%" bgcolor="white">
			<tr>
				<td class="titolotab" colspan="3"><b>Certificati</b></td>
			</tr>
			<tr>
				<td class="VertSxAlta" width="95%" colspan="2"><b>A97</b>
					<% if(A97_3bar46_link != null && A97_6bar46_link != null){%>
					Certificato di Attestazione di Residenza Fiscale in Stato diverso da quello Italiano (disponibile in Modulistica: mod. <a href="<%=A97_3bar46_link%>" target="_blank">3/46</a> per persone fisiche o mod. <a href="<%=A97_6bar46_link%>" target="_blank">6/46</a> per persone giuridiche)
					<%}else{ %>
					Certificato di Attestazione di Residenza Fiscale in Stato diverso da quello Italiano
					<%} %>
					</td>
				<td class="VertDxAlta" width="5%" align="center"><%= indicatoreA97 %>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta" colspan="2"><b>A96</b> Modello di Autocertificazione per la non applicazione delle imposte nei confronti dei soggetti non residenti
				<a href="http://www.agenziaentrate.gov.it/wps/content/Nsilib/Nsi/Documentazione/Fiscalita+internazionale/White+list+e+Autocertificazione/Autocertificazione/" target="_blank">(http://www.agenziaentrate.gov.it/wps/content/.../Autocertificazione/)</a>
				</td>
				<td class="VertDxAlta" align="center"><%= indicatoreA96 %>&nbsp;</td>
			</tr>
			<%--
	<tr>
		<td class="VertSxAlta" colspan="2"><b>A95</b> Certificato di Attestazione Residenza Fiscale in Stato appartente alla White List</td>
		<td class="VertDxAlta" align="center"><%= indicatoreA95 %>&nbsp;</td>
	</tr>
--%>
			<tr>
				<td class="VertSxAlta" colspan="2"><b>Regime dei minimi</b> </td>
				<td class="VertDxAlta" align="center"><%= regimeDeiMinimi %>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta" colspan="2">Data attivazione (gg/mm/aaaa)</td>
				<td class="VertDxAlta" align="center"><%= regimeDataAttivazione %>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta" colspan="2">Data revoca (gg/mm/aaaa)</td>
				<td class="VertDxAlta" align="center"><%= regimeDataRevoca %>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta" colspan="2">Data scadenza  (gg/mm/aaaa)</td>
				<td class="VertDxAlta" align="center"><%= regimeDataScadenza %>&nbsp;</td>
			</tr>


		</table>
		<table width="100%" bgcolor="white">
			<tr>
				<td class="titolotab" colspan="3"><b>Soggetto USA</b></td>
			</tr>
			<sm:includeIfEventAllowed eventName="fatca_soggetto_usa" eventDescription="fatca_soggetto_usa">
			<tr>
				<td class="VertSxAlta" colspan="2"><b>FATCA SOGGETTO USA</b></td>
				<td class="VertDxAlta" align="center"><%=fatcaSoggettoUSA %>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta" colspan="2"><b>FATCA STATUS</b></td>
				<td class="VertDxAlta" align="center"><%=fatcaStatus %>&nbsp;</td>
			</tr>
			</sm:includeIfEventAllowed>
			<tr>
				<td class="VertSxAlta" colspan="2"><b>Presenza di indizi</b></td>
				<td class="VertDxAlta" align="center"><%=presenzaDiIndizi %>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta" colspan="2"><b>Numero sicurezza sociale/TIN</b></td>
				<td class="VertDxAlta" align="center"><%=numSic %>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta" colspan="2"><b>W8BEN</b> Certificate of Foreign Status of Beneficial
				Owner for United States Tax Withholding</td>
				<td class="VertDxAlta" align="center"><%= w8 %>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta" colspan="2"><b>W9</b> Request for Taxpayer Identification Number and Certification</td>
				<td class="VertDxAlta" align="center"><%= w9 %>&nbsp;</td>
			</tr>
		</table>
		<% } %>
		<table width="100%" bgcolor="white">
			<tr>
				<td colspan="6" class="titolotab"><b>Documenti</b></td>
				<td class="titolotab" width="55%" align="right" colspan="4">
				<%  if (idForModifica != null ) { %>
				<sm:includeIfEventAllowed eventName="CronistoriaDocumenti" eventDescription="Cronistoria Documenti">
					<input type="button" name="DocumentiCronistoria" value="Cronistoria Documenti" style="cursor:hand" 
					onClick="submitMe('CronistoriaDocumenti')" class="bottone">
				</sm:includeIfEventAllowed>
				<%} %>
				&nbsp;
				<%if(showModify){%>
					<input type="Button" name="AttributiFiscaliDocumentiModifica" value="Modifica" style="cursor:hand" 
					onClick="submitMe('AttributiFiscaliDocumentiModifica')" class="bottone">
				<%}%>
				</td>
			</tr>
			<%
  	  		if(documentoCollection!=null && documentoCollection.size() > 0)  {
	  	  			boolean isPSRPSDocumentPresent = false;
	        		boolean otherDocuments = false;

  		  			Iterator iterator = documentoCollection.iterator();
    				size = documentoCollection.size();
            		for(int i=0; i<size; i++) {
              			documentoView =(DocumentoPFView)iterator.next();
              			if ( "Registrazione Tribunale".equals(documentoView.getTipoDocumento().getCausale()) ||
              		 			 "RPS".equals(documentoView.getTipoDocumento().getCausale()) ||
              		 			 "RRPS".equals(documentoView.getTipoDocumento().getCausale())||
              		 			 "CRPS".equals(documentoView.getTipoDocumento().getCausale()) ||
              		 			 "Green card".equals(documentoView.getTipoDocumento().getCausale()) || "PS".equals(documentoView.getTipoDocumento().getCausale()) || ("CS".equals(documentoView.getTipoDocumento().getCausale()) && documentoView.getDataEmissione()!=null && new DateHandler().isDateMoreThanSpecifiedYears(documentoView.getDataEmissione(),ICensimentoPFConstants.DOC_PREFILL_SCANDENZA_CARATA_BEFORECOMP_YEAR))) {
              					isPSRPSDocumentPresent = true;
              		 		} else {
              		 			otherDocuments = true;
              		 		}
    				}
    				if(otherDocuments ) {
        %>
			<tr>
				<td class="VertDxAlta DAIPFANTCI" colspan="10"><b><font color="red">Documenti validi ai fini dell'identificazione antiriciclaggio:</font></b></td>
			</tr>
			<tr>
				<td class="VertSxAlta" width="10%">Data Inserimento</td>
				<td class="VertSxAlta" width="8%">Utente Inseritore</td>
				<td class="VertSxAlta" width="14%">Tipo Documento</td>
				<td class="VertSxAlta" width="12%">Numero Documento</td>
				<td class="VertSxAlta" width="10%" nowrap>Ente Emissione</td>
				<td class="VertSxAlta" width="10%" nowrap>Luogo Emissione</td>
				<td class="VertSxAlta" width="11%">Data Emissione</td>
				<td class="VertSxAlta" width="11%">Data Scadenza</td>
				<td class="VertSxAlta" width="7%">ID scansione</td>
				<td class="VertSxAlta" width="7%">&nbsp;</td>
			</tr>
			<%
        				strDescrizione = "";
        				iterator = documentoCollection.iterator();
						size = documentoCollection.size();
						for(int i=0; i<size; i++) {
  							documentoView =(DocumentoPFView)iterator.next();
  							if ((documentoView.getDataFineValidita() == null || documentoView.getDocumentoId() == null) && !"Registrazione Tribunale".equals(documentoView.getTipoDocumento().getCausale()) &&
  					 			  !"RPS".equals(documentoView.getTipoDocumento().getCausale()) &&
  					 			  !"RRPS".equals(documentoView.getTipoDocumento().getCausale()) &&
  					 			  !"CRPS".equals(documentoView.getTipoDocumento().getCausale()) && 
  					 			  !"Green card".equals(documentoView.getTipoDocumento().getCausale()) && !"PS".equals(documentoView.getTipoDocumento().getCausale()) && !("CS".equals(documentoView.getTipoDocumento().getCausale()) && documentoView.getDataEmissione()!=null && new DateHandler().isDateMoreThanSpecifiedYears(documentoView.getDataEmissione(),ICensimentoPFConstants.DOC_PREFILL_SCANDENZA_CARATA_BEFORECOMP_YEAR))) {
	       						strDescrizione = documentoView.getTipoDocumento()!=null ? documentoView.getTipoDocumento().getDescrizione() : "";
								String strDataEmissione = documentoView.getDataEmissione() != null ? new DateHandler().formatDate(documentoView.getDataEmissione(),"dd-MM-yyyy") : "";
								String strDataScadenza = documentoView.getDataScadenza() != null ? new DateHandler().formatDate(documentoView.getDataScadenza(),"dd-MM-yyyy") : "";
								String strDocInsertedDate = documentoView.getDocInsertedDate() != null ? new DateHandler().formatDate(documentoView.getDocInsertedDate(),"dd-MM-yyyy") : "";
         %>
			<tr>
				<td class="VertDxAlta"><%= strDocInsertedDate %>&nbsp;</td>
				<td class="VertDxAlta" ><%= documentoView.getDocInsertedUser() != null ? documentoView.getDocInsertedUser() : "" %>&nbsp;</td>
				<td class="VertDxAlta"><%= strDescrizione %>&nbsp;</td>
				<td class="VertDxAlta"><%=documentoView.getDocumentoNumero()%>&nbsp;</td>
				<td class="VertDxAlta"><%=documentoView.getEnteEmissione()%>&nbsp;</td>
				<td class="VertDxAlta"><%=documentoView.getLuogoEmissione()%>&nbsp;</td>
				<td class="VertDxAlta" nowrap="nowrap"><%=strDataEmissione%>&nbsp;</td>
				<td class="VertDxAlta" nowrap="nowrap"><%=strDataScadenza%>&nbsp;</td>
				<td class="VertDxAlta"><%=documentoView.getIdDoc()%>&nbsp;</td>
				
				<td class="VertDxAlta">
				<% if(documentoView.getIdDoc() != null || documentoView.getIssId()!=null) {%>
						<sm:includeIfEventAllowed eventName="UploadFiles" eventDescription="UploadFiles">
							<a href="javascript:submitMeAfterClickingImage('UploadFiles','<%= documentoView.getIdDoc()%>');" onMouseOver="link('Allega Documenti Identità');return true;" onMouseOut="cancella()">
                    		<img src="/H2O/HomePageClienteIntranet/img/docid.png" alt="Allega documento identità" border="0" width="29" height="19"></a>
                    	</sm:includeIfEventAllowed>
                 <% } else {%>
                	 &nbsp;&nbsp;
                 <%}
				  if(documentoView.getIssId()!=null) {%>
                    	<sm:includeIfEventAllowed eventName="viewDetails" eventDescription="viewDetails"> 
                    		<a href="javascript:submitMeAfterClickingImage('viewDetails', <%= documentoView.getIssId()%>);" onMouseOver="link('Iss');return true;" onMouseOut="cancella()">
                     		<img src="/x-net/img/ico_mydocs.gif" alt="Visualizza i documenti archiviati" border="0" ></a>
                      	</sm:includeIfEventAllowed>
                <% }%>
                </td>
			</tr>
			<%  				}
          				}
              		}
					if(isPSRPSDocumentPresent ) {
		%>
			<tr>
				<td class="VertDxAlta DAIPFAGGIU" colspan="10"><b><font color="red">Documenti NON validi ai fini dell'identificazione antiriciclaggio:</font></b></td>
			</tr>
			<tr>
				<td class="VertSxAlta" width="10%">Data Inserimento</td>
				<td class="VertSxAlta" width="8%">Utente Inseritore</td>
				<td class="VertSxAlta" width="14%">Tipo Documento</td>
				<td class="VertSxAlta" width="12%">Numero Documento</td>
				<td class="VertSxAlta" width="10%" nowrap>Ente Emissione</td>
				<td class="VertSxAlta" width="10%" nowrap>Luogo Emissione</td>
				<td class="VertSxAlta" width="11%">Data Emissione</td>
				<td class="VertSxAlta" width="11%">Data Scadenza</td>
				<td class="VertSxAlta" width="7%">ID scansione</td>
				<td class="VertSxAlta" width="7%">&nbsp;</td>
			</tr>
			<%
				        strDescrizione = "";
				        iterator = documentoCollection.iterator();
						size = documentoCollection.size();
						for(int i=0; i<size; i++) {
				  			documentoView =(DocumentoPFView)iterator.next();
				  			if ((documentoView.getDataFineValidita() == null || documentoView.getDocumentoId() == null) && ("Registrazione Tribunale".equals(documentoView.getTipoDocumento().getCausale()) ||
									 "RPS".equals(documentoView.getTipoDocumento().getCausale()) ||
									 "RRPS".equals(documentoView.getTipoDocumento().getCausale()) ||
									 "CRPS".equals(documentoView.getTipoDocumento().getCausale()) || "Green card".equals(documentoView.getTipoDocumento().getCausale()) || "PS".equals(documentoView.getTipoDocumento().getCausale()) || ("CS".equals(documentoView.getTipoDocumento().getCausale()) && documentoView.getDataEmissione()!=null && new DateHandler().isDateMoreThanSpecifiedYears(documentoView.getDataEmissione(),ICensimentoPFConstants.DOC_PREFILL_SCANDENZA_CARATA_BEFORECOMP_YEAR)))) {
	  								strDescrizione = documentoView.getTipoDocumento()!=null ? documentoView.getTipoDocumento().getDescrizione() : "";
 	 								String strDataEmissione = documentoView.getDataEmissione() != null ? new DateHandler().formatDate(documentoView.getDataEmissione(),"dd-MM-yyyy") : "";
	  								String strDataScadenza = documentoView.getDataScadenza() != null ? new DateHandler().formatDate(documentoView.getDataScadenza(),"dd-MM-yyyy") : "";
	  								String strDocInsertedDate = documentoView.getDocInsertedDate() != null ? new DateHandler().formatDate(documentoView.getDocInsertedDate(),"dd-MM-yyyy") : "";

		%>
			<tr>
				<td class="VertDxAlta"><%= strDocInsertedDate %>&nbsp;</td>
				<td class="VertDxAlta" ><%= documentoView.getDocInsertedUser() != null ? documentoView.getDocInsertedUser() : "" %>&nbsp;</td>
				<td class="VertDxAlta"><%= strDescrizione %>&nbsp;</td>
				<td class="VertDxAlta"><%=documentoView.getDocumentoNumero()%>&nbsp;</td>
				<td class="VertDxAlta"><%=documentoView.getEnteEmissione()%>&nbsp;</td>
				<td class="VertDxAlta"><%=documentoView.getLuogoEmissione()%>&nbsp;</td>
				<td class="VertDxAlta" nowrap="nowrap"><%=strDataEmissione%>&nbsp;</td>
				<td class="VertDxAlta" nowrap="nowrap"><%=strDataScadenza%>&nbsp;</td>
				<td class="VertDxAlta"><%=documentoView.getIdDoc()%>&nbsp;</td>
				<td class="VertDxAlta">
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
                </td>
			</tr>
			<%  				}
				        }
					}
  	  		}
		%>
		<tr>
				<td class="VertSxAlta" colspan="3"><b>Modalità di identificazione del cliente</b> </td>
				<td class="VertDxAlta" colspan="7"><%=attributiEsterniView!= null && attributiEsterniView.getModalita()!= null ? attributiEsterniView.getModalita().getDescrizione() : ""%>&nbsp;</td>
			</tr>
</table>
</table>
<br>
<% if(!((helper.checkForMotiv(motivCollection,"ANTCI") || helper.checkForMotiv(motivCollection,"POSTE")) && !helper.isExistsuperiorMotivThanAntci(motivCollection))) { %>
<% if( intermediariError != null ) { %>
<table width="100%" border="1" cellspacing="0" cellpadding="5"
	bordercolor="#CCCCCC" align="center">
	<tr>
		<td class="titolotab" height="35" align="left"><img
			src="/img/h2o/triangolo.gif" width="25" height="22" hspace="10"
			align="absmiddle"><%= intermediariError %></td>
	</tr>
</table>
<br>
<% } if(eventiError != null) { %>
<table width="100%" border="1" cellspacing="0" cellpadding="5"
	bordercolor="#CCCCCC" align="center">
	<tr>
		<td class="titolotab" height="35" align="left"><img
			src="/img/h2o/triangolo.gif" width="25" height="22" hspace="10"
			align="absmiddle"><%= eventiError %></td>
	</tr>
</table>
<br>
<% } %>

<table class="topH2O" width="100%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
		<table width="100%" bgcolor="white">
			<tr>
				<td colspan="4" class="titolotab"><b>Intermediari</b></tD>
				<%if(showModify){%>
				<td align="right" class="titolotab"><input type="Button"
					name="IntermediariEventiMemoModifica" value="Modifica"
					style="cursor:hand"
					onClick="submitMe('IntermediariEventiMemoModifica')"
					class="bottone"></td>
				<%} else {%>
				<td align="right" class="titolotab">&nbsp;</td>
				<%}%>
			</tr>
			<tr>
				<td class="VertSxAlta" width="20%">Nome</td>
				<td class="VertSxAlta" width="20%">Cognome</td>
				<td class="VertSxAlta" width="20%">Tipo Intermediario</td>
				<td class="VertSxAlta" width="20%" >Codice Dip. / Prom.</td>
				<td class="VertSxAlta" width="20%" >Data inizio collegamento</td>
			</tr>
			<%
           if(dipendenteCollection != null)
           {
             size = dipendenteCollection.size();
             Iterator iterator = dipendenteCollection.iterator();
             RicercaDipendenteView ricercaDipendenteView = null;
             for(int i=0; i<size; i++)
             {
               ricercaDipendenteView = (RicercaDipendenteView)iterator.next();
        %>
			<tr>
				<td class="VertDxAlta"><%= ricercaDipendenteView.getNome()%>&nbsp;</td>
				<td class="VertDxAlta"><%= ricercaDipendenteView.getCognome()%>&nbsp;</td>
				<td class="VertDxAlta">Dipendente</td>
				<td class="VertDxAlta" ><%= ricercaDipendenteView.getCodiceDipendente() %>&nbsp;</td>
				<td class="VertDxAlta" ><%= ricercaDipendenteView.getDataInizioCollegamento() %>&nbsp;</td>
			</tr>
			<% }
           } %>
			<%
           if(promotoreCollection != null)
           {
             size = promotoreCollection.size();
             Iterator iterator = promotoreCollection.iterator();
             RicercaPromotoreView ricercaPromotoreView = null;
             for(int i=0; i<size; i++)
             {
               ricercaPromotoreView = (RicercaPromotoreView)iterator.next();
        %>
			<tr>
				<td class="VertDxAlta"><%= ricercaPromotoreView.getNome()%>&nbsp;</td>
				<td class="VertDxAlta"><%= ricercaPromotoreView.getCognome()%>&nbsp;</td>
				<td class="VertDxAlta">Promotore</td>
				<td class="VertDxAlta" ><%= ricercaPromotoreView.getCodicePromotore() %>&nbsp;</td>
				<td class="VertDxAlta" ><%= ricercaPromotoreView.getDataInizioCollegamento()%>&nbsp;</td>
			</tr>
			<% }
           }
    if(sviluppatoreCollection != null)
    {
      size = sviluppatoreCollection.size();
      Iterator iterator = sviluppatoreCollection.iterator();
      RicercaSviluppatoreView ricercaSviluppatoreView = null;
      for(int i=0; i<size; i++)
      {
        ricercaSviluppatoreView = (RicercaSviluppatoreView)iterator.next();
        %>
			<tr>
				<td class="VertDxAlta"><%= ricercaSviluppatoreView.getNome()%>&nbsp;</td>
				<td class="VertDxAlta"><%= ricercaSviluppatoreView.getCognome()%>&nbsp;</td>
				<td class="VertDxAlta">Sviluppatore</td>
				<td class="VertDxAlta"><%= ricercaSviluppatoreView.getCodiceIntermediari() %>&nbsp;</td>
				<td class="VertDxAlta"><%= ricercaSviluppatoreView.getDataInizioCollegamento() %>&nbsp;</td>
			</tr>
			<% }
    } %>

			<% if(origineClienteView != null ) { %>
			<tr class="titolotab">
				<td colspan="5"><b>Origine Cliente</b></td>
			</tr>
			<tr>
				<td class="VertSxAlta" width="20%">Dipendente o Promotore o
				Sviluppatore</td>
				<td class="VertSxAlta" width="20%">Campagna</td>
				<td class="VertSxAlta" width="40%">8 cifre Segnalatore (se il soggetto è proposto da un segnalatore SELEZIONARE SOLO QUESTA OPZIONE)</td>
				<td class="VertSxAlta" colspan="2">Altro</td>
			</tr>
			<tr>
				<% if (origineClienteView.getTipoId() != null && "INTERMEDIARI".equals(origineClienteView.getTipoId())) { %>
				<td class="VertDxAlta"><%= origineClienteView.getCampagnaDesc() != null ? origineClienteView.getCampagnaDesc() : "" %>&nbsp;</td>
				<td class="VertDxAlta">&nbsp;</td>
				<td class="VertDxAlta">&nbsp;</td>
				<td class="VertDxAlta" colspan="2">&nbsp;</td>
				<% } else if(origineClienteView.getTipoId() != null && "CAMPAGNA".equals(origineClienteView.getTipoId())) { %>
				<td class="VertDxAlta">&nbsp;</td>
				<td class="VertDxAlta"><%= origineClienteView.getCampagnaDesc() != null ? origineClienteView.getCampagnaDesc() : "" %>&nbsp;</td>
				<td class="VertDxAlta">&nbsp;</td>
				<td class="VertDxAlta" colspan="2">&nbsp;</td>
				<% } else if(origineClienteView.getTipoId() != null && "SEGNALATORE".equals(origineClienteView.getTipoId())) { %>
				<td class="VertDxAlta">&nbsp;</td>
				<td class="VertDxAlta">&nbsp;</td>
				<td class="VertDxAlta"><%= origineClienteView.getCampagnaDesc() != null ? origineClienteView.getCampagnaDesc() : "" %>&nbsp;</td>
				<td class="VertDxAlta" colspan="2">&nbsp;</td>
				<% } else { %>
				<td class="VertDxAlta">&nbsp;</td>
				<td class="VertDxAlta">&nbsp;</td>
				<td class="VertDxAlta">&nbsp;</td>
				<td class="VertDxAlta" colspan="2"><%= origineClienteView.getCampagnaDesc() != null ? origineClienteView.getCampagnaDesc() : "" %>&nbsp;</td>
				<% } %>
			</tr>
			<% } %>

		</table>
		<table width="100%" bgColor="white">
			<tr>
				<td colspan="4" class="titolotab"><b>Eventi</b></td>
				<%if(showModify){%>
				<td align="right" class="titolotab"><input type="Button"
					name="IntermediariEventiMemoModifica" value="Modifica"
					style="cursor:hand"
					onClick="submitMe('IntermediariEventiMemoModifica')"
					class="bottone"></td>
				<%} else {%>
				<td align="right" class="titolotab">&nbsp;</td>
				<%}%>
			</tr>
			<tr>
				<td class="VertSxAlta" width="30%">Tipo Evento</td>
				<td class="VertSxAlta" width="30%">Note</td>
				<td class="VertSxAlta" width="20%">Data Inizio</td>
				<td class="VertSxAlta" width="20%" colspan="2">Data Fine</td>
			</tr>
			<%
            if(eventoViewCollection != null)
            {
               Iterator iterator = eventoViewCollection.iterator();
               size = eventoViewCollection.size();
               DateHandler dateHandler = new DateHandler();
               for(int i=0; i<size; i++)
               {
                  eventoView = (SoggettoEventoView)iterator.next();
                  strDescrizione="";
                  if(eventoView.getTipoEvento()!=null)
                  {
                    strDescrizione=eventoView.getTipoEvento().getDescrizione();
                  }
        %>
			<tr>
				<td class="VertDxAlta"><%=strDescrizione%>&nbsp;</td>
				<td class="VertDxAlta"><%=eventoView.getNote()%>&nbsp;</td>
				<% if(eventoView.getDataInizio()!=null){%>
				<td class="VertDxAlta"><%=dateHandler.formatDate(eventoView.getDataInizio(),"dd-MM-yyyy")%>&nbsp;</td>
				<% } else { %>
				<td class="VertDxAlta">&nbsp;</td>
				<% } if(eventoView.getDataFine()!=null) { %>
				<td class="VertDxAlta" colspan="2"><%=dateHandler.formatDate(eventoView.getDataFine(),"dd-MM-yyyy")%>&nbsp;</td>
				<% } else { %>
				<td class="VertDxAlta" colspan="2">&nbsp;</td>
				<% } %>
			</tr>
			<% }
           } %>
		</table>
		<table width="100%" bgColor="white">
			<tr>
				<td colspan="4" class="titolotab"><b>Memo</b></td>
				<%if(showModify){%>
				<td align="right" class="titolotab"><input type="Button"
					name="IntermediariEventiMemoModifica" value="Modifica"
					style="cursor:hand"
					onClick="submitMe('IntermediariEventiMemoModifica')"
					class="bottone"></td>
				<%} else {%>
				<td align="right" class="titolotab">&nbsp;</td>
				<%}%>
			</tr>
			<tr>
				<td class="VertSxAlta" width="30%">Testo</td>
				<td class="VertSxAlta" width="30%">Modalità di presentazione</td>
				<td class="VertSxAlta" width="20%">Data Decorrenza</td>
				<td class="VertSxAlta" width="20%" colspan="2">Data Scadenza</td>
			</tr>
			<% if(memoViewCollection != null)
          {
              Iterator iterator = memoViewCollection.iterator();
              size = memoViewCollection.size();
              DateHandler dateHandler = new DateHandler();
              for(int i=0; i<size; i++)
              {
                memoView =(MemoView)iterator.next();
          %>
			<tr>
				<td class="VertDxAlta"><%=memoView.getMemoTesto()%>&nbsp;</td>
				<td class="VertDxAlta"><%=memoView.getPresentazione()%>&nbsp;</td>
				<% if(memoView.getDecorrenza()!=null) {%>
				<td class="VertDxAlta"><%=dateHandler.formatDate(memoView.getDecorrenza(),"dd-MM-yyyy")%>&nbsp;</td>
				<%}else{%>
				<td class="VertDxAlta">&nbsp;</td>
				<% } if(memoView.getScadenza()!=null) { %>
				<td class="VertDxAlta" colspan="2"><%=dateHandler.formatDate(memoView.getScadenza(),"dd-MM-yyyy")%>&nbsp;</td>
				<% } else { %>
				<td class="VertDxAlta" colspan="2">&nbsp;</td>
				<% } %>
			</tr>
			<% }
           } %>
		</table>
		</td>
	</tr>
</table>

<br>

<% if(collegateError != null) { %>
<table width="100%" border="1" cellspacing="0" cellpadding="5"
	bordercolor="#CCCCCC" align="center">
	<tr>
		<td class="titolotab" height="35" align="left"><img
			src="/img/h2o/triangolo.gif" width="25" height="22" hspace="10"
			align="absmiddle"><%= collegateError %></td>
	</tr>
</table>
<br>
<% } %>

<% if(poteriFirmaErrorMessage != null) { %>
<table width="100%" border="1" cellspacing="0" cellpadding="5"
	bordercolor="#CCCCCC" align="center">
	<tr>
		<td class="titolotab" height="35" align="left"><img
			src="/img/h2o/triangolo.gif" width="25" height="22" hspace="10"
			align="absmiddle"><%= poteriFirmaErrorMessage %></td>
	</tr>
</table>
<br>
<% } %>

<table class="topH2O" width="100%" cellpadding="1" cellspacing="0">

	<tr>
		<td>
		<table width="100%" bgcolor="white">
			<tr>
				<td class="titolotab" colspan="4"><b>Persone Collegate</b></td>
				<td height="2" class="titolotab" align="right" colspan="2">
				<%  if (idForModifica != null ) { %>
					<sm:includeIfEventAllowed eventName="CronistoriaPoteriFirma" eventDescription="Cronistoria PoteriFirma">
						<input type="button" name="poteriCronistoria" value="Cronistoria PoteriFirma" style="cursor:hand" onClick="submitMe('CronistoriaPoteriFirma')" class="bottone">
					</sm:includeIfEventAllowed>
				<%} %>
				&nbsp;
				<%if(showModify){%>
					<input type="Button"
					name="CollegateAggiungi" value="Modifica" style="cursor:hand"
					onClick="submitMe('CollegateAggiungi')" class="bottone">
				<%}%>
				</td>			
			</tr>
			<tr>
				<td class="VertSxAlta" width="18%">Nome</td>
				<td class="VertSxAlta" width="18%">Cognome</td>
				<td class="VertSxAlta" width="12%">Data di Nascita</td>
				<td class="VertSxAlta" width="15%">Tipo Collegamento</td>
				<td class="VertSxAlta" width="25%">Tipo documento</td>
				<td class="VertSxAlta" width="12%">Data documento</td>
			</tr>
			<%
             if(collegateViews != null)
             {
               IDocPoteriFirmaView poteriFirmaView = null;
               size = collegateViews.size();
               Collection collegateViewCollection = collegateViews.values();
               Iterator collegateViewIterator = collegateViewCollection.iterator();
               CollegatePFView collegatePFView = null;
               for(int i=0; i<size; i++)
               {
                 collegatePFView = (CollegatePFView)collegateViewIterator.next();
                 poteriFirmaView = collegatePFView.getLastValidPoteriFirmaDocView();
                 String tipoDoc = "";
                 if(poteriFirmaView != null && poteriFirmaView.getTipoDocumento() != null) {
                	 tipoDoc = "AT".equals(poteriFirmaView.getTipoDocumento().getCausale()) ? poteriFirmaView.getTipoDocumento().getDescrizione() + "(" + poteriFirmaView.getDocumentDescription() + ")" : poteriFirmaView.getTipoDocumento().getDescrizione();
                 }
          %>
			<tr>
				<td class="VertDxAlta"><%= collegatePFView.getNome() %>&nbsp;</td>
				<td class="VertDxAlta"><%= collegatePFView.getCognome() %>&nbsp;</td>
				<% if(collegatePFView.getDataDiNascita()!=null) { %>
				<td class="VertDxAlta"><%= new DateHandler().formatDate(collegatePFView.getDataDiNascita(),"dd-MM-yyyy") %>&nbsp;</td>
				<% } else { %>
				<td class="VertDxAlta">&nbsp;</td>
				<% } %>
				<td class="VertDxAlta"><%= collegatePFView.getTypeOfCollegateDescrizione() %>&nbsp;</td>
				<td class="VertDxAlta"><%= tipoDoc != null ? tipoDoc : "" %>&nbsp;</td>
				<td class="VertDxAlta"><%= poteriFirmaView != null && poteriFirmaView.getDataEmissione() != null ? new DateHandler().formatDate(poteriFirmaView.getDataEmissione(),"dd-MM-yyyy") : "" %>&nbsp;</td>
			</tr>
			<% }
             } %>
		</table>
		</td>
	</tr>
</table>
<% } %> <br>
<% if(codiciSoggettoError != null) { %>
<table width="100%" border="1" cellspacing="0" cellpadding="5"
	bordercolor="#CCCCCC" align="center">
	<tr>
		<td class="titolotab" height="35" align="left"><img
			src="/img/h2o/triangolo.gif" width="25" height="22" hspace="10"
			align="absmiddle"><%= codiciSoggettoError %></td>
	</tr>
</table>
<br>
<% } %>

<table class="topH2O" width="100%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
		<table width="100%" bgColor="white">
			<tr>
				<td colspan="2" class="titolotab"><b>Elenco Codici Soggetto</b></td>
			</tr>
			<%
                    String codiceNdg = "";
                    String codiceHost = "";
                    String codiceNR = "";
                    String codiceCR = "";
                    String codfo = "";
                    String codiceCRA = "";
                    String codiceDipendente = "";
                    String codicePromotore = "";
                    String codiceSviluppatore = "";
                   // String codiceLM = "";
                    //String codiceCliente = "";
                    if(codiceSoggettoPFView != null)
                    {
                        codiceNdg = codiceSoggettoPFView.getNdg();
                        codiceHost = codiceSoggettoPFView.getCodiceHost();
                        if (codiceHost != null) {
                            String temp = codiceHost+";";
                            StringTokenizer stringTokenizer = new StringTokenizer(temp,";");
                            while(stringTokenizer.hasMoreTokens()) {
                                if(stringTokenizer.nextToken().startsWith("0")) {
                                    clienteIndirettoCheck = true;
                                    break;
                                }
                            }
                        } else {
                            clienteIndirettoCheck = true;
                        }
                        codiceNR = codiceSoggettoPFView.getCnr();
                        codiceCR = codiceSoggettoPFView.getCodiceCentraleRischi();
                        codiceCRA = codiceSoggettoPFView.getCcra();
                        codiceDipendente = codiceSoggettoPFView.getCoddp();
                      //  codiceLM = codiceSoggettoPFView.getCodlm();
                        codicePromotore = codiceSoggettoPFView.getCodpr();
                        codiceSviluppatore = codiceSoggettoPFView.getCodsv();
                        codfo=codiceSoggettoPFView.getCodfo() ;
                        //codiceCliente = codiceSoggettoPFView.getCodcl();
                    } else {
                        clienteIndirettoCheck = true;
                    }
                %>
            <sm:includeIfEventAllowed eventName="SoggettoIDDisplayInRiepilogoPage" eventDescription="SoggettoIDDisplayInRiepilogoPage">
				<tr>
					<td class="VertSxAlta">Soggetto Id</td>
					<td class="VertDxAlta"><%= idForModifica %>&nbsp;</td>
				</tr>
			</sm:includeIfEventAllowed>

			<tr>

				<td class="VertSxAlta" width="45%">Codice NDG</td>
				<td class="VertDxAlta" width="55%"><%= codiceNdg %> &nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta">Codice Host (8Cifre)</td>
				<td class="VertDxAlta"><%= buildCodiceHost(codiceHost) %>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta">Codice Numerazione Rapporti</td>
				<td class="VertDxAlta"><%= codiceNR %>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta">Codice Centrale Rischi</td>
				<td class="VertDxAlta"><%= codiceCR %>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta">Codice Fornitore</td>
				<td class="VertDxAlta"><%= codfo %>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta">Codice Centrale Rischi Associativa</td>
				<td class="VertDxAlta"><%= codiceCRA %>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta">Codice Dipendente</td>
				<td class="VertDxAlta"><%= codiceDipendente %>&nbsp;</td>
				</tr>
			<!--<tr>
				<td class="VertSxAlta">Codice Libro Matricola</td>
				<td class="VertDxAlta"> codiceLM &nbsp;</td>
				</tr>
			<tr>
				--><td class="VertSxAlta">Codice Promotore</td>
				<td class="VertDxAlta"><%= codicePromotore %>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta">Codice Sviluppatore</td>
				<td class="VertDxAlta"><%= codiceSviluppatore %>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta">Codice Cliente</td>
				<td class="VertDxAlta"><%= view.getOutputAttribute("CODCL") %>&nbsp;</td>
			</tr>
			<tr>
				<td clasS="VertSxAlta">Apertura 8 cifre host a cliente indiretto</td>
				<td class="VertDxAlta"><% if(clienteIndirettoCheck) { %> <input
					type="checkbox" name="updateDiretto" value="checked"><br>
				<% } else { %> <input type="checkbox" name="updateDiretto"
					value="checked" checked><br>
				<% } %></td>
			</tr>
			<%	if(isEmployee != null && isEmployee.booleanValue()){ %>
			<tr>
				<td colspan="2" class="VertDxAlta" width="30%"><b>Soggetto Dipendente di una societa del gruppo</b></td>
			</tr>
			<%	}  %>
		</table>
		</td>
	</tr>
</table>

<% if(segnalatoreError != null) { %>
<br>
<table width="100%" border="1" cellspacing="0" cellpadding="5"
	bordercolor="#CCCCCC" align="center">
	<tr>
		<td class="titolotab" height="35" align="left"><img
			src="/img/h2o/triangolo.gif" width="25" height="22" hspace="10"
			align="absmiddle"><%= segnalatoreError %></td>
	</tr>
</table>

<% } %>
<%
	if (showModify && idForModifica != null ) {
%>
<br>
<table class="topH2O" width="100%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
		<table width="100%" bgColor="white">
	       <tr>
				<td  class="titolotab"><b>Segnalatore</b></td>

				<td width="55%" align="right" class="titolotab">
				<sm:includeIfEventAllowed eventName="SegnalatoreModifica">
					<input	type="Button" name="SegnalatoreModifica" value="Modifica"  style="cursor:hand"
					 onClick="submitMe('SegnalatoreModifica')"	class="bottone">
			     </sm:includeIfEventAllowed>
				 </td>
			</tr>
			<tr>
				<td class="VertSxAlta">Codice</td>
				<td class="VertDxAlta">
				<%= attributiEsterniView != null && attributiEsterniView.getCosg() != null ?
						attributiEsterniView.getCosg() : ""  %>&nbsp;</td>
			<tr>
				<td class="VertSxAlta">Succursale</td>
				<td class="VertDxAlta">
				<%= attributiEsterniView != null && attributiEsterniView.getSusg() != null ?
						attributiEsterniView.getSusg() : ""  %>&nbsp;</td>
			<tr>
				<td class="VertSxAlta">Data acquisizione segnalatore</td>
				<td class="VertDxAlta">
				<%= attributiEsterniView != null && attributiEsterniView.getDisg() != null ?
						attributiEsterniView.getDisg() : ""  %>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta">Data Revoca Segnalatore</td>
				<td class="VertDxAlta">
				<%= attributiEsterniView != null && attributiEsterniView.getDfsg() != null ?
						attributiEsterniView.getDfsg() : ""  %>&nbsp;</td>
			</tr>
			<tr>
				<td class="VertSxAlta">Dipendente che ha reclutato</td>
				<td class="VertDxAlta">
				<%= attributiEsterniView != null && attributiEsterniView.getSegdp() != null ?
						attributiEsterniView.getSegdp() : ""  %>&nbsp;<br>
			    <%= attributiEsterniView != null && attributiEsterniView.getSegdpIntestazione() != null ?
						attributiEsterniView.getSegdpIntestazione() : ""  %>&nbsp;
			    </td>
			</tr>
		</table>
	</td>
 </tr>
</table>

<% } %>
<br>
<%  if(modifica != null && logViews != null) { %>
<table width="100%" class="Interna">
	<%
			int lgsize = logViews.size();
			Iterator iterator = logViews.iterator();
			LogView logView = null;
			for(int i=0; i<lgsize; i++)
			{
				logView = (LogView)iterator.next();
        %>
	<tr>
		<% if("I".equals(logView.getModeOfOperation())) { %>
		<td class="VertSxAlta" width="30%">Censito Da</td>
		<% } else { %>
		<td class="VertSxAlta" width="30%">Ultima Modifica</td>
		<% } %>
		<td class="VertDxAlta" width="35%"><%= logView.getCodiciDipendente() %></td>
		<td class="VertDxAlta" width="35%"><%= new DateHandler().formatDate(logView.getDateOfOperation(),"dd-MM-yyyy") %></td>
	</tr>
	<% } %>
</table>
<% } %> <br>
<sm:includeIfEventAllowed eventName="ConfermaNoHost" eventDescription="ConfermaNoHost">
	<table width="100%">
		<tr>
			<td class="VertSxAlta" width="30%">Motivazione operazione (*)</td>
			<td class="VertDxAlta" width="35%">
				<input type="text" name="motivazione" size="50">
			</td>
			<td class="VertDxAlta" width="35%">
				<sm:includeIfEventAllowed eventName="ConfermaNoHost" eventDescription="ConfermaNoHost">
					<input type="Submit" name="<sm:getEventParamName/>" value="<sm:getEventParamValue/>" style="cursor:hand">
				</sm:includeIfEventAllowed>
			</td>
		</tr>
		<tr>
			<td class="VertDxAlta" align = "Right" colspan="3">
				<sm:includeIfEventAllowed eventName="Create8Cifre">
					<input type="Button" name="Create8Cifre" value="Create8Cifre" style="cursor:hand" onClick="submitMe('Create8Cifre')">
				</sm:includeIfEventAllowed>
			</td>
		</tr>
	</table>
</sm:includeIfEventAllowed> <% if(idForModifica == null) { %>
<table width="100%">
	<tr>
		<td class="VertDxAlta">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
		<td class="VertDxAlta" colspan="2"><a
			href="/x-net/intranet/credito_commerciale/impieghi/legge_risparmio.jsp"
			target="new"> <font color="red">ATTENZIONE!!! Prima di confermare
		verificare che il soggetto NON sia sottoposto alle restrizioni<br>
		dell'art.136 del testo Unico Bancario "esponenti aziendali di società
		del Gruppo e da queste<br>
		controllate quali amminstratori, sindaci e direttori" . (La conferma
		del censimento attesta<br>
		l'avvenuta verifica)</font></a></td>
	</tr>
</table>
<% } %> <br>
<table width="100%">
	<tr>
		<td width="25%" align="center">
			<input type="Button" name="Annulla" value="Annulla" style="cursor:hand" onClick="submitMe('Annulla')">
		</td>
		<% if(modifica == null) { %>
		<td width="25%" align="center">
			<input type="Button" name="RPFIndietro" value="Indietro" style="cursor:hand" onClick="submitMe('RPFIndietro')">
		</td>
		<% } else { %>
		<input type="hidden" name="Modifica" value="M">
		<td width="25%" align="center">&nbsp;</td>
		<% } %>
		<%if(showModify){%>
		<td width="50%" align="center">
			<sm:includeIfEventAllowed eventName="ConfermaSocket" eventDescription="CONFERMASocket">
				<input type="Button" name="ConfermaSocket" value="CONFERMASocket" style="cursor:hand" onClick="submitMe('ConfermaSocket')">
			</sm:includeIfEventAllowed>
			<sm:includeIfEventAllowed eventName="Conferma" eventDescription="Conferma">
				<input type="Submit" name="<sm:getEventParamName/>" value="<sm:getEventParamValue/>" style="cursor:hand">
			</sm:includeIfEventAllowed>
		</td>
		<td width="25%" align="center">&nbsp;
			<!-- <sm:includeIfEventAllowed eventName="ConfermaCerved">
			   <input type="Button" name="ConfermaCerved" value="ConfermaCerved" style="cursor:hand" onClick="submitMe('ConfermaCerved')">
			</sm:includeIfEventAllowed> -->
		</td>
		<%} else {%>
		<td width="25%" align="center">&nbsp;</td>
		<%}%>
	</tr>
</table>
</form>
