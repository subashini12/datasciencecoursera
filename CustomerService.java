package it.sella.anagrafe.soaservices.services;

import it.sella.anagrafe.GestoreAnagrafeException;
import it.sella.anagrafe.LoggerTags;
import it.sella.anagrafe.XMLSchemaValidationException;
import it.sella.anagrafe.schema_validation.SchemaValidator;
import it.sella.anagrafe.sm.admin.GestoreAnagrafeArgHandler;
import it.sella.anagrafe.soaservices.exception.AnagrafeServiceException;
import it.sella.anagrafe.soaservices.msg.IValidationMessage;
import it.sella.anagrafe.soaservices.util.LogDataGenerator;
import it.sella.anagrafe.soaservices.util.SetXMLHandler;
import it.sella.anagrafe.soaservices.validator.SOAInputDataValidator;
import it.sella.anagrafe.util.StringHandler;
import it.sella.anagrafe.util.logger.AnagrafeLoggerView;
import it.sella.anagrafe.util.logger.SecurityLoggerBuilder;
import it.sella.anagrafe.util.marshaller.GenericMarshaller;
import it.sella.anagrafe.util.types.MinmlCustomerResultView;
import it.sella.util.Log4Debug;
import it.sella.util.Log4DebugFactory;

import java.rmi.RemoteException;

import javax.xml.bind.JAXBException;

public class CustomerService extends LogDataGenerator {
	
	private static final Log4Debug log4Debug = Log4DebugFactory.getLog4Debug(CustomerService.class);
	private static final String METHOD_NAME = "creaSoggettoXMLWithXSDValidation";
	private static final String XSDKEY = "PFMINML_XSD";
	private static final String LOGGER_OPERATION_CODE = "ANAG-SOA-CRE-CUS-MIN";
	
	
	 /*
	  * creation of Minml Customer by using the given xml.
	  */
	 public String createMinmlCustomer(final String anagSOAStringXML) throws AnagrafeServiceException, RemoteException {
		log4Debug.debug("CustomerService > createMinmlCustomer > anagSOAStringXML : ", anagSOAStringXML);
		boolean operationSuccess = true;
		String errorMessage = null;
		String outputXML = "";
		Long soggettoId = null;
		try {
			SOAInputDataValidator.validateInputXML(anagSOAStringXML);
			new SchemaValidator().validate(anagSOAStringXML, XSDKEY);
			outputXML = (String) GestoreAnagrafeArgHandler.getResult(METHOD_NAME, anagSOAStringXML);
			soggettoId = validateAndGetSoggettoId(outputXML);
		} catch (final GestoreAnagrafeException e) {
			operationSuccess = false;
			errorMessage = e.getMessage();
			log4Debug.warnStackTrace(e);
			throw new AnagrafeServiceException(e);
		} catch (RemoteException e) {
			operationSuccess = false;
			errorMessage = e.getMessage();
			log4Debug.warnStackTrace(e);
			throw new AnagrafeServiceException(e);
		} catch (XMLSchemaValidationException e) {
			operationSuccess = false;
			errorMessage = IValidationMessage.XML_INVALID + " : " + e.getMessage();
			log4Debug.warnStackTrace(e);
			throw new AnagrafeServiceException(errorMessage);
		} finally {
			logCreateMinmlCustomer(anagSOAStringXML, operationSuccess,	errorMessage, outputXML, soggettoId);
		}
		return "<RESULT>OK</RESULT>";
	}

	 /*
	  * validation of the outputXML given by anagrafe API. 
	  * If Esito is "1", then throw the exception with the given errormessage. 
	  * otherwise if Esito is "0", then return the created soggettoID for logger purpose.
	  */
	private Long validateAndGetSoggettoId(String outputXML) throws GestoreAnagrafeException {
		log4Debug.debug("validateOutputXML > outputXML : ", outputXML);
		Long createdSoggettoID = null;
		StringBuffer errorMsg = new StringBuffer("");
		try {
			MinmlCustomerResultView outputView = (MinmlCustomerResultView) GenericMarshaller.unMarshallAsObject(outputXML, MinmlCustomerResultView.class);
			if (outputView != null) {
				if ("1".equals(outputView.getESITO())) {
					for (String msg : outputView.getERRORMSG()) {
						errorMsg.append(msg).append(",");
					}
					throw new GestoreAnagrafeException(errorMsg.toString());	
				} else if("0".equals(outputView.getESITO())) {
					createdSoggettoID = Long.valueOf(outputView.getSOGGETTOID());
					log4Debug.debug("createdSoggettoID : ", createdSoggettoID);
				}
			}
		} catch (JAXBException e) {
			log4Debug.debug("JAXBException : ", e.getMessage());
			throw new GestoreAnagrafeException(e.getMessage());
		}
		return createdSoggettoID;
	}

	/*
	 * Creation of security loggerview. 
	 */
	private void logCreateMinmlCustomer(final String anagSOAStringXML,final boolean operationSuccess,final String errorMessage,final String outputXML,final	Long soggettoId) {
		log4Debug.debug("operationSuccess : ", operationSuccess, ", errorMessage : ", errorMessage, ", outputXML : ", outputXML);
		final AnagrafeLoggerView loggerView = new AnagrafeLoggerView();
		loggerView.setSoggettoId(soggettoId);
		loggerView.setOperationCode(LOGGER_OPERATION_CODE);
		loggerView.setInputXML(SetXMLHandler.getTagWithNullCheck(LoggerTags.INSERIMENTO.getValue(), anagSOAStringXML));
		loggerView.setOutputXML(getOutputXml(errorMessage, outputXML));
		if (operationSuccess){
			loggerView.withSuccess();
		} else {
			loggerView.withError(errorMessage);
		}
		log4Debug.debug("loggerView : ", loggerView);
		new SecurityLoggerBuilder().buildLoggerWithGivenOutputXML(loggerView);
	}
	
	/*
	 * Build the outputXML for security logger.
	 */
	private String getOutputXml(final String errorMsg, final String outputXMLData) {
		final StringHandler stringHandler = new StringHandler();
		final StringBuffer logBuffer = new StringBuffer();
		SetXMLHandler.addStartTag(logBuffer, LoggerTags.RESULT.getValue());
		if(stringHandler.isEmpty(errorMsg)) {
			logBuffer.append(SetXMLHandler.getTagWithNullCheck(LoggerTags.STATUS.getValue(), "OK"));
		} else {
			logBuffer.append(SetXMLHandler.getTagWithNullCheck(LoggerTags.STATUS.getValue(), "KO"));
			logBuffer.append(StringHandler.escapeXMLTagValue(SetXMLHandler.getTagWithValueCheckAndCDATATag(LoggerTags.ERRORE.getValue(), errorMsg)));
		}
		logBuffer.append(StringHandler.escapeXMLTagValue(SetXMLHandler.getTagWithValueCheckAndCDATATag(LoggerTags.OUTPUT_XML.getValue(), outputXMLData)));
		SetXMLHandler.addEndTag(logBuffer, LoggerTags.RESULT.getValue());
		return SetXMLHandler.getTagWithNullCheck(LoggerTags.OUTPUT.getValue(), logBuffer.toString());
    }
}
