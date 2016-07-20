<%@ taglib uri="/statemachine.tld" prefix="sm" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<c:set var="mainSoggetto" value="${mainSoggetto}" ></c:set>
<c:set var="replaceSoggetto" value="${replaceSoggetto}"></c:set>
<c:set var="closeLinks" value="${closeLinks}"></c:set>
<script type="text/javascript" src="/script/Anagrafe/jquery-1.7.min.js"></script>
<script>
$(document).ready(function() {
	$("#Conferma").focus();
}); 
function submitConferma(){
	<sm:includeIfEventAllowed eventName="Conferma">
    	document.mergesoggettoconfermaform.action = "<sm:getEventMainURL/>";
    	document.mergesoggettoconfermaform.submit() ;
	</sm:includeIfEventAllowed>	
}
</script>
<form name="mergesoggettoconfermaform" method="post" action="<sm:getMainURL/>" >
<table width="70%" border="1"  align="center">
<tr>
            <td class="titolotab" width="70%" colspan="2" align="center"> <b>Are You Sure You Want To Merge The Soggetto ?</b></td>
    </tr>	
	<tr>
		<td  width="35%">Soggetto da tenere</td>
		<td  width="35%" id="mainsoggetto" >
		<c:out value="${mainSoggetto}"/>
		</td>
	</tr>			
	<tr>	   		
		<td  width="35%">Soggetto da eliminare</td>
		<td  width="35%" id="replacesoggetto" >
			<c:out value="${replaceSoggetto}"/>
		</td>
	</tr>
	<tr>	   		
		<td  width="35%">Chiudere anche i collegamenti ?</td>
		<td  width="35%" >
		
		<c:choose>
		<c:when test="${closeLinks ne null and closeLinks eq 'TRUE' }">
			<c:out value="Si"/>
		</c:when>
		<c:otherwise>
			<c:out value="No"/>
		</c:otherwise>
			</c:choose>
		</td>
	</tr>

    <tr >
        
       <td align=center colspan="3">
            <sm:includeIfEventAllowed eventName="Indietro" eventDescription="Indietro">
            <input type="submit"  name="<sm:getEventParamName/>"  value="<sm:getEventParamValue/>" style="cursor:hand" >
            </sm:includeIfEventAllowed>
       &nbsp;&nbsp;&nbsp;&nbsp;
            <sm:includeIfEventAllowed eventName="Conferma" eventDescription="Conferma">
            <input type="button" id="Conferma" name="<sm:getEventParamName/>"  value="<sm:getEventParamValue/>" style="cursor:hand" onclick="submitConferma();">
            </sm:includeIfEventAllowed>
        </td>
    </tr>
</table>

</form>
