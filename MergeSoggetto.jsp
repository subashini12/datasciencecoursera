<%@ taglib uri="/statemachine.tld" prefix="sm" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<c:set var="mainSoggetto" value="${mainSoggetto}"></c:set>
<c:set var="replaceSoggetto" value="${replaceSoggetto}"></c:set>
<c:set var="errorMessage" value="${errorMessage}"></c:set>
<c:set var="closeLinks" value="${closeLinks}"></c:set>

<script type="text/javascript" src="/script/Anagrafe/jquery-1.7.min.js"></script>
<script>
$(document).ready(function() {
	$("#Conferma").focus();
	$("#errormssg").text("");
	$("#Conferma").click(function() { 
		var firstSoggetto= $.trim($("#mainsoggetto").val());
		var secondSoggetto= $.trim($("#replacesoggetto").val());
		var filter = /^[0-9]*$/;
		var error = 0;
		if ( firstSoggetto == "" || secondSoggetto == "")  { 
			$("#errormssg").text("Please Enter tenere And eliminare Soggetto Id");
			error = 1; 
		} 
		else {
		var filter = /^[0-9]*$/;
		
		if (!filter.test(firstSoggetto)|| !filter.test(secondSoggetto))
		{
			$("#errormssg").text("SoggettoId cannot have Alphabets!"); 
			error = 1; 
		}
		else if (firstSoggetto == secondSoggetto) { 
			$("#errormssg").text("Both tenere And eliminare Soggetto Id Cannot Be Same");
			error = 1; 
		}
		
	}
		if(error != 1 ){
			submitConferma();
		}else{
			$('#javaerror').hide();
		}
	});
	
	$('#closeLinkcheck').change(function(){
        if($(this).attr('checked')){
        	 $("#closeLinks").val("TRUE");
        	 $('#closeLinkcheck').attr('checked','checked');
        }else{
        	 $("#closeLinks").val("FALSE");
        	 $('#closeLinkcheck').removeAttr("checked");
        }
   });
});
</script> 
<script type="text/javascript">
function submitConferma(){
	<sm:includeIfEventAllowed eventName="Conferma">
    	document.mergesoggettoform.action = "<sm:getEventMainURL/>";
    	document.mergesoggettoform.submit() ;
	</sm:includeIfEventAllowed>	
}
function submitAnnulla(){
	<sm:includeIfEventAllowed eventName="Annulla">
    	document.mergesoggettoform.action = "<sm:getEventMainURL/>";
    	document.mergesoggettoform.submit() ;
	</sm:includeIfEventAllowed>	
}
</script>
 
<span id="javaerror" style="color: red">
 <c:if test="${errorMessage ne null}">
  <center>
           <hr color=red>
           <c:out value="${errorMessage}"/> <br>
           <hr color=red>
        </center>
 </c:if>
</span>
<center>
<span id="errormssg" style="color: red"></span><br /> 
 </center>
<body>
<form name="mergesoggettoform" method="post" action="<sm:getMainURL/>" >
<!-- check whether this is required -->
<!--<form name="MergeSoggettoAdmin" method="post" action="<sm:getMainURL/>"  novalidate="novalidate">
-->

<table width="70%" border="1"  align="center">
	<tr>
            <td class="titolotab" width="70%" colspan="2" align="center"> <b>Funzione di compattamento soggetti</b></td>
    </tr>

	<tr>
		<td  width="35%" align="center">Soggetto da tenere</td>
		<td width="35%" align="center">
			  <input type="text" name="mainsoggetto" tabindex="1" id="mainsoggetto" class="testocombo" value="<c:out value="${mainSoggetto}"/>"/>
		</td>
	</tr>			
	<tr>	   		
		<td  width="35%" align="center">Soggetto da eliminare</td>
		<td  width="35%" align="center">
			<input  type="text"  name="replacesoggetto" tabindex="2" id="replacesoggetto" class="testocombo" value="<c:out value="${replaceSoggetto}"/>">
		</td>
	</tr>
	<tr>	   		
		<td  width="35%" align="center">Chiudere anche i collegamenti ?</td>
		<td  width="35%" align="center">
          <input  type="checkbox" ${(closeLinks != 'FALSE') ? 'checked' : ''} name="closeLinkcheck" id="closeLinkcheck" tabindex="3" value="${(closeLinks ne 'FALSE') ? 'TRUE' : 'FALSE'}"/>
		</td>
	</tr>
	
	<input type="hidden" name="closeLinks" id="closeLinks" value="${(closeLinks ne 'FALSE') ? 'TRUE' : 'FALSE'}">
    <tr>
        <td align=center colspan="3">
            <sm:includeIfEventAllowed eventName="Annulla" eventDescription="Annulla">
            <input type="button" name="<sm:getEventParamName/>" tabindex="4" value="<sm:getEventParamValue/>" style="cursor:hand" onclick="submitAnnulla();">
            </sm:includeIfEventAllowed>
        &nbsp;&nbsp;&nbsp;&nbsp;
            <sm:includeIfEventAllowed eventName="Conferma" eventDescription="Conferma">
            <input type="button" id="Conferma" tabindex="5" name="<sm:getEventParamName/>"  value="<sm:getEventParamValue/>" style="cursor:hand">
            </sm:includeIfEventAllowed>
        </td>
    </tr>
</table>
</form>
</body>