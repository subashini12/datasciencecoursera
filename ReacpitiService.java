/**
 * 
 */
package it.sella.anagrafe.soaservices.services;

import it.sella.anagrafe.SubSystemHandlerException;
import it.sella.anagrafe.implementation.ClassificazioneHandler;
import it.sella.anagrafe.implementation.RecapitiView;
import it.sella.anagrafe.pf.SoggettoRecapitiView;
import it.sella.anagrafe.soaservices.exception.AnagrafeServiceException;
import it.sella.anagrafe.soaservices.exception.RecapitiValidationException;
import it.sella.anagrafe.soaservices.msg.IValidationMessage;
import it.sella.anagrafe.soaservices.soadata.IRecapitiData;
import it.sella.anagrafe.soaservices.soadata.SOADataAccessFactory;
import it.sella.anagrafe.soaservices.util.InfoAnagRecapitiXMLReader;
import it.sella.anagrafe.soaservices.util.InfoAnagrafeXMLReader;
import it.sella.anagrafe.soaservices.util.InfoRecapitiXMLGenerator;
import it.sella.anagrafe.soaservices.util.SOASecurityLogger;
import it.sella.anagrafe.soaservices.util.SetXMLHandler;
import it.sella.anagrafe.soaservices.validator.SOAInputDataValidator;
import it.sella.anagrafe.soaservices.view.InfoAnagRecapSoggView;
import it.sella.anagrafe.soaservices.view.InfoAnagRecapitiView;
import it.sella.anagrafe.soaservices.view.InfoAnagrafeView;
import it.sella.util.Log4Debug;
import it.sella.util.Log4DebugFactory;

import java.rmi.RemoteException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/**
 * @author gbs02406
 * 
 */
public class ReacpitiService {
	private static final Log4Debug log4Debug =Log4DebugFactory.getLog4Debug(ReacpitiService.class);
	
	public String getRecapitiDetails(final String anagSOAStringXML)throws AnagrafeServiceException {
		Long soggettoId = null;
		boolean operationSuccess = true;
		String errorMessage = null;
		try {
			SOAInputDataValidator.validateInputXML(anagSOAStringXML);
			final InfoAnagrafeView infoAnagrafeView = (InfoAnagrafeView) new InfoAnagrafeXMLReader(
					anagSOAStringXML).getInputValueFromXML();
			soggettoId = SOAInputDataValidator.validateAndGetSoggettoIdLong(infoAnagrafeView.getCodiceIB(), true, true);
			final List<RecapitiView> recapitiViewList = ((IRecapitiData)SOADataAccessFactory.getInstance().getRecapitiDataFinder()).getRecapitiDetails(soggettoId);
			return InfoRecapitiXMLGenerator.getRecapitiXMLTagfromList(recapitiViewList);
		} catch (final AnagrafeServiceException e) {
			operationSuccess = false;
			errorMessage = e.getMessage();
			log4Debug.severeStackTrace(e);
			throw new AnagrafeServiceException(e);
		}finally{
			SOASecurityLogger.setSecurityLog(soggettoId, "SOA-getRecapitiDetails", anagSOAStringXML, "ANAG-SOA-GET-REC", operationSuccess, errorMessage);	
		}
	}
	
	public String setRecapitiDetails(final String anagSOAStringXML)throws AnagrafeServiceException ,RecapitiValidationException {
		Long soggettoId = null;
		boolean operationSuccess = true;
		String errorMessage = null;
		try {
			SOAInputDataValidator.validateInputXML(anagSOAStringXML);
			final InfoAnagRecapSoggView infoAnagRecapSoggView = new InfoAnagRecapitiXMLReader(anagSOAStringXML).getInputValueFromXML();
			soggettoId = SOAInputDataValidator.validateAndGetSoggettoIdLong(infoAnagRecapSoggView.getCodiceIB(), true, true);
			final List<InfoAnagRecapitiView> infoAnagRecapitiList = infoAnagRecapSoggView.getRecapitiList();
			log4Debug.debug("---RecapitiListSize----", (infoAnagRecapitiList != null ? infoAnagRecapitiList.size() : "Empty"));
			if(infoAnagRecapitiList.size() == 0){
				throw new RecapitiValidationException(IValidationMessage.XML_INVALID);
			}
			final List<SoggettoRecapitiView> soggettoRecapitiViewList = getSoggettoRecapitiView(infoAnagRecapitiList);
			SOAInputDataValidator.validateRecapiti(soggettoRecapitiViewList, soggettoId);
			((IRecapitiData)SOADataAccessFactory.getInstance().getRecapitiDataFinder()).setRecapitiDetails(soggettoId,soggettoRecapitiViewList);
			return SetXMLHandler.getSuccessResultXMLTag();
			} catch (final AnagrafeServiceException e) {
				operationSuccess = false;
				errorMessage = e.getMessage();
				log4Debug.severeStackTrace(e);
				throw new AnagrafeServiceException(e);
			}finally{
				SOASecurityLogger.setSecurityLog(soggettoId, "SOA-setRecapitiDetails", anagSOAStringXML, "ANAG-SOA-SET-REC", operationSuccess, errorMessage);	
			}
	}
	
	private List<SoggettoRecapitiView> getSoggettoRecapitiView(final List<InfoAnagRecapitiView> infoAnagRecapitiList) throws AnagrafeServiceException{
		
		final List<SoggettoRecapitiView> soggettoRecapitiViewList = new ArrayList<SoggettoRecapitiView>();
		final int size = infoAnagRecapitiList.size();
		final Iterator<InfoAnagRecapitiView > iterator = infoAnagRecapitiList.iterator();
		try {
		for (int i=0; i<size;i++) {
			final SoggettoRecapitiView soggettoRecapitiView = new SoggettoRecapitiView();
			final InfoAnagRecapitiView infoAnagRecapitiView = iterator.next();
			soggettoRecapitiView.setValoreRecapiti(infoAnagRecapitiView.getRecapitiValue());
			soggettoRecapitiView.setRiferimento(infoAnagRecapitiView.getRiferimento());
			soggettoRecapitiView.setTipoRecapiti(
					ClassificazioneHandler.getClassificazioneView(infoAnagRecapitiView.getTipoRecapiti(), "TIPO_RECAPITO"));
			soggettoRecapitiViewList.add(soggettoRecapitiView);
		}
		} catch (final RemoteException e) {
			log4Debug.severeStackTrace(e);
			throw new AnagrafeServiceException(e);
		} catch (final SubSystemHandlerException e) {
			log4Debug.severeStackTrace(e);
			throw new AnagrafeServiceException(e);
		}
		return soggettoRecapitiViewList;
	}
	
}
