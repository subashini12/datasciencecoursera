<%@ taglib uri="/statemachine.tld" prefix="sm"%>
<%@ page
	import="java.util.List,java.util.ArrayList,it.sella.anagrafe.sm.admin.AdminConstants,it.sella.statemachine.View,it.sella.classificazione.ClassificazioneView,java.util.Collection,it.sella.anagrafe.implementation.AnagrafeCompatibilityView"%>
<head>
<script type="text/javascript">

function submitConferma(){
	<sm:includeIfEventAllowed eventName="Conferma">
    	document.ConfigForm.action = "<sm:getEventMainURL/>";
    	document.ConfigForm.submit() ;
	</sm:includeIfEventAllowed>	
}


</script>

</head>
<body>
<%
	View reqView = (View) session.getAttribute("view");
	List<AnagrafeCompatibilityView> adminView = (List<AnagrafeCompatibilityView>) reqView.getOutputAttribute("listOfBanks");
	Collection<ClassificazioneView> configCollection = (Collection<ClassificazioneView>) reqView.getOutputAttribute("ClassViewList");
	String errorMessage = (String) reqView.getOutputAttribute("errorMessage");
	String successMessage = (String) reqView.getOutputAttribute("successMessage");
	String classId=reqView.getInputAttribute("classId") != null ? (String)reqView.getInputAttribute("classId") : "";
%>

<%
	if (errorMessage != null) {
%>
<table width="100%" border="1" cellspacing="0" cellpadding="5"
	bordercolor="#CCCCCC" align="center">
	<tr>
		<td class="titolotab" height="35" align="left" ><img
			src="/img/h2o/triangolo.gif" width="25" height="22" hspace="10"
			align="absmiddle"><%=errorMessage%></td>
	</tr>
</table>
<br>
<%
	}
%>
<%
	if (errorMessage == null && successMessage != null) {
%>
<span id="javaerror">
<table width="100%" border="1" cellspacing="0" cellpadding="5"
	bordercolor="#CCCCCC" align="center">
	<tr >
		<td class="titolotab" height="35" align="center" id="errorMessage"><font color="red"><B><%=successMessage%></td>
	</tr>
</table>
</span>
<br>
<%
	}
%>
<script type="text/javascript" src="/script/Anagrafe/jquery-1.9.1.js"></script>
<form name="ConfigForm" action="<sm:getMainURL/>" method="post">
<jsp:include page="ErrorHandle.jsp" />
<table border="1" width="100%" align="center">
	<th colspan="6" align="center">Anagrafe Compatibility</th>
	<%
		if (configCollection != null && !configCollection.isEmpty() ) {
	%>
	<tr>
		<td colspan="3" align="center"><b>Select Causale Tobe Configured : </b></td>
		<td colspan="3" align="center"><select class="TestoCombo"
			name="classId" id="classId" style="width: 550px">
			<Option selected value="--Select--">--Seleziona--</option>
			<%
						for (ClassificazioneView classficazioneObj : configCollection) {
			%>
			<Option value="<%= classficazioneObj.getId() %>"
				<%= classficazioneObj.getId().toString().equals(classId) ? "selected" : "" %>><%= classficazioneObj.getCausale()%></Option>

			<%
					}
			%>
		</select></td>
	</tr>
	<%
		}
	%>
	<%if(!"".equals(classId) && !"--Select--".equals(classId) && classId!=null && adminView != null ) {%>
	<tr class="details">
		<td colspan="6">
		<table style="width: 100%;">
			<tr class="highlight">
				<td align="center"><span id="causaleMssg"> </span></td>
			</tr>
		</table>
		</td>
	</tr>
	<%} %>
	<%
		if (adminView != null && !adminView.isEmpty()) {
	%>
	<tr class="checkforbank">

		<th colspan="3">Bank ID</th>
		<th colspan="3">Allowed</th>
	</tr>
	<%
		for (AnagrafeCompatibilityView view : adminView) {
			%>
	<tr class="checkforbank">
		<td colspan="3" align="center"><%=view.getBankId()%></td>
		<td colspan="3" align="center"><select class="TestoCombo" name="anagrafecompt"  id="anagrafecompt" >
		<option value=<%=view.getBankId()+"^"+view. getAttributeName().getId() +"^true"%> <%="true".equals(view.getAllowed())  ?"Selected" : "" %>>Allowed</option>
			<option value=<%=view.getBankId()+"^"+view.getAttributeName(). getId() +"^false"%> <%="false".equals(view.getAllowed())? "Selected" : ""%>>Not Allowed </option>
		</select></td>
	</tr>
	<%
				}
				}
			%>
	<tr>
		<td colspan="6" align="Center"> 
		<sm:includeIfEventAllowed eventName="Conferma" eventDescription="Conferma">
			<input type="Submit" name="<sm:getEventParamName/>"
				value="<sm:getEventParamValue/>" style="cursor: hand">
		</sm:includeIfEventAllowed>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
		<%if(adminView!=null){ %>
		<span id="Update">
	<sm:includeIfEventAllowed eventName="Update" eventDescription="Update">
			<input type="Submit"  name="<sm:getEventParamName/>"
				value="<sm:getEventParamValue/>" style="cursor: hand">
		</sm:includeIfEventAllowed> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
		</span>
		<%} %>
		 <sm:includeIfEventAllowed eventName="Annulla" eventDescription="Annulla">
			<input type="Submit" name="<sm:getEventParamName/>"
				value="<sm:getEventParamValue/>" style="cursor: hand">
		</sm:includeIfEventAllowed>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
	</tr>
</table>

<script type="text/javascript">
$(document).ready(function(){
	displayMessage();
	  $('#classId').change(function(e){
		loadClassificazione();
}); 
});
function loadClassificazione() {
	var classId="<%=classId%>";
	var value =$("#classId option:selected").text();
	var valueId =$("#classId option:selected").val();
	var compVal =$("#anagrafecompt option:selected").val();
	displayMessage();
	  if( value != "--Seleziona--" && compVal !=null ){
			 submitConferma(); 
			}else{
				 $('#Update').hide();
				 $('.checkforbank').hide();
			}
		 if(classId != valueId ){
			  $('.details').hide();
			  $('#javaerror').hide();
		  }else{
			  
			  $('.details').show(); 
		  } 
}
function displayMessage() {
	var value =$("#classId option:selected").text();
	if(value != null && value != "--Seleziona--"){
		  $("#causaleMssg").text('You Are Updating For This Causale:'+value);
		  }
}
</script>



</form>
</body>
