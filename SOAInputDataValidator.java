package it.sella.anagrafe.soaservices.validator;

import it.sella.anagrafe.CanalePreferitoDataView;
import it.sella.anagrafe.GestoreAnagrafeException;
import it.sella.anagrafe.GestoreSoggettoException;
import it.sella.anagrafe.SubSystemHandlerException;
import it.sella.anagrafe.common.MotivoDiCensimento;
import it.sella.anagrafe.controllo.ControlloDatiException;
import it.sella.anagrafe.dbaccess.TipoSoggettoHandler;
import it.sella.anagrafe.pf.DatiPrivacyPFFiveLevelView;
import it.sella.anagrafe.pf.SoggettoRecapitiView;
import it.sella.anagrafe.soaservices.exception.AnagrafeServiceException;
import it.sella.anagrafe.soaservices.exception.RecapitiValidationException;
import it.sella.anagrafe.soaservices.msg.IValidationMessage;
import it.sella.anagrafe.util.MotivHandler;
import it.sella.anagrafe.util.SecurityHandler;
import it.sella.anagrafe.validator.CanalePreferitoValidator;
import it.sella.anagrafe.validator.DatiPrivacyValidator;
import it.sella.anagrafe.validator.IRPValidatorHandler;
import it.sella.util.Log4Debug;
import it.sella.util.Log4DebugFactory;

import java.rmi.RemoteException;
import java.util.Collection;
import java.util.List;

public class SOAInputDataValidator {
	private static final Log4Debug log4Debug =Log4DebugFactory.getLog4Debug(SOAInputDataValidator.class);

	public static Long validateAndGetSoggettoIdLong(final String codiceIB, final boolean isPLAllowed, final boolean isAZAllowed  )throws AnagrafeServiceException {
		Long soggettoId = null;

		try {
			if (codiceIB == null || "".equals(codiceIB.trim())) {
				throw new AnagrafeServiceException(IValidationMessage.CODICE_IB_INVALID);
			}
			soggettoId = SecurityHandler.getSoggettoIdForUser(codiceIB);
			if(soggettoId == null){
				throw new AnagrafeServiceException(IValidationMessage.CODICE_IB_INVALID);
			}
			validateSoggettoIdAllowed(isPLAllowed, isAZAllowed, soggettoId);
		}  catch (final GestoreSoggettoException e) {
			log4Debug.warnStackTrace(e);
			throw new AnagrafeServiceException(e);
		} catch (final RemoteException e) {
			log4Debug.severeStackTrace(e);
			throw new AnagrafeServiceException(e);
		} catch (final SubSystemHandlerException e) {
			log4Debug.warnStackTrace(e);
			throw new AnagrafeServiceException(e);
		}
		return soggettoId;
	}

	public static Long validateAndGetSoggettoId(final String soggettoIdStr, final boolean isPLAllowed, final boolean isAZAllowed  )throws AnagrafeServiceException {
		Long soggettoId = null;

		try {
			if (soggettoIdStr == null || "".equals(soggettoIdStr.trim())) {
				throw new AnagrafeServiceException(IValidationMessage.SOGGETTO_ID_INVALID);
			}
			try{
				soggettoId = Long.valueOf(soggettoIdStr);
			}catch (final NumberFormatException e) {
				throw new AnagrafeServiceException(IValidationMessage.SOGGETTO_ID_INVALID);
			}
			validateSoggettoIdAllowed(isPLAllowed, isAZAllowed, soggettoId);
		}  catch (final GestoreSoggettoException e) {
			log4Debug.warnStackTrace(e);
			throw new AnagrafeServiceException(e);
		} catch (final RemoteException e) {
			log4Debug.severeStackTrace(e);
			throw new AnagrafeServiceException(e);
		}
		return soggettoId;
	}

	private static void validateSoggettoIdAllowed(final boolean isPLAllowed,
			final boolean isAZAllowed, final Long soggettoId)
			throws GestoreSoggettoException, RemoteException,
			AnagrafeServiceException {
		final TipoSoggettoHandler tipoSoggettoHandler = new TipoSoggettoHandler();
		final String tipoSoggetto = tipoSoggettoHandler
				.getTipoSoggetto(soggettoId);
		if (tipoSoggetto == null || !("Semplice".equals(tipoSoggetto) ||
				(isPLAllowed && "Plurintestazione".equals(tipoSoggetto)) ||
				( isAZAllowed && "AZIENDE".equals(tipoSoggettoHandler.getParentTipoSoggetto(soggettoId))))) {
			throw new AnagrafeServiceException(IValidationMessage.SOGGETTO_ID_INVALID);
		}
	}

	public static void validateRecapiti(final List<SoggettoRecapitiView> soggettoRecapitiViewList, final Long soggettoId)
			throws RecapitiValidationException, AnagrafeServiceException {
		try {
			final Collection motiv = new MotivHandler().getMotiviWithBank(soggettoId);
			final String tipoSoggetto = new TipoSoggettoHandler().getTipoSoggetto(soggettoId);
			new IRPValidatorHandler().validateRecapitiCollection(soggettoRecapitiViewList, motiv , true, tipoSoggetto, false, soggettoId);
		} catch (final RemoteException e) {
			log4Debug.severeStackTrace(e);
			throw new AnagrafeServiceException(e);
		} catch (final ControlloDatiException e) {
			log4Debug.severeStackTrace(e);
			throw new RecapitiValidationException(getErrorMsgWithOutErrorCode(e.getMessage()));
		} catch (final GestoreAnagrafeException e) {
			log4Debug.severeStackTrace(e);
			throw new AnagrafeServiceException(e);
		}
	}

	public static void validatePrivacy(final DatiPrivacyPFFiveLevelView datiPrivacyPFFiveLevelView, final Long soggettoId)
	throws RecapitiValidationException, AnagrafeServiceException {
		try {
			final Collection motiv = new MotivHandler().getMotiviWithBank(soggettoId);
			final String tipoSoggetto = new TipoSoggettoHandler().getTipoSoggetto(soggettoId);
			new DatiPrivacyValidator().validateDetails(datiPrivacyPFFiveLevelView, motiv, tipoSoggetto, true,false);
		} catch (final RemoteException e) {
			log4Debug.severeStackTrace(e);
			throw new AnagrafeServiceException(e);
		} catch (final ControlloDatiException e) {
			log4Debug.severeStackTrace(e);
			throw new RecapitiValidationException(getErrorMsgWithOutErrorCode(e.getMessage()));
		} catch (final GestoreAnagrafeException e) {
			log4Debug.severeStackTrace(e);
			throw new AnagrafeServiceException(e);
		}
	}

	public static String getErrorMsgWithOutErrorCode(final String errorMsg){
		final StringBuffer errorMsgBuffer = new StringBuffer();
		final String errorMsgArr[] = errorMsg.split("\\^");
		final int length = errorMsgArr.length;
		String tempArr[] = null;
		if(length > 0 && errorMsg.contains("^")){
			for (int i = 0; i < length; i++) {
				tempArr = errorMsgArr[i].split("\\$");
				if(tempArr.length ==2){
					errorMsgBuffer.append(tempArr[1]+"^");
				}else{
					errorMsgBuffer.append(errorMsgArr[i]).append("^");
				}
			}
		}else{
			return errorMsg;
		}
		return errorMsgBuffer.toString();

	}

	/**
	 * 
	 * @param canalePreferitoDataView
	 * @param recapitiViewsList
	 * @param soggettoId
	 * @throws RecapitiValidationException
	 * @throws AnagrafeServiceException
	 */
	public static void validateCanalePreferito(final CanalePreferitoDataView canalePreferitoDataView,final List<SoggettoRecapitiView> recapitiViewsList,final Long soggettoId)
	throws RecapitiValidationException, AnagrafeServiceException {
		try {
			final Collection<MotivoDiCensimento> motiv = new MotivHandler().getMotiviWithBank(soggettoId);
			new CanalePreferitoValidator().validateCanalePreferitoData(canalePreferitoDataView, recapitiViewsList, true, motiv);

		} catch (final RemoteException e) {
			log4Debug.severeStackTrace(e);
			throw new AnagrafeServiceException(e);
		} catch (final ControlloDatiException e) {
			log4Debug.severeStackTrace(e);
			throw new RecapitiValidationException(getErrorMsgWithOutErrorCode(e.getMessage()));
		} catch (final GestoreAnagrafeException e) {
			log4Debug.severeStackTrace(e);
			throw new AnagrafeServiceException(e);
		}
	}
	
	public static void validateInputXML(final String soaAnagStringXml) throws AnagrafeServiceException{
		if(soaAnagStringXml == null){
			throw new AnagrafeServiceException(IValidationMessage.XML_INVALID);
		}
	}
}
