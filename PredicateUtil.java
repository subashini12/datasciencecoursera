package it.sella.anagrafe.predicate;

import java.sql.Timestamp;

import it.sella.anagrafe.IDAIRegoleDetailsView;
import it.sella.anagrafe.InformazioneManagerException;
import it.sella.anagrafe.SubSystemHandlerException;
import it.sella.anagrafe.factory.IMCreationException;
import it.sella.anagrafe.factory.IMFactory;
import it.sella.anagrafe.pf.DocumentoPFView;
import it.sella.anagrafe.pf.SoggettoRecapitiView;
import it.sella.anagrafe.util.DateHandler;
import it.sella.anagrafe.util.HelperException;
import it.sella.anagrafe.util.SecurityHandler;
import it.sella.anagrafe.view.CompDocumentView;
import it.sella.util.Log4Debug;
import it.sella.util.Log4DebugFactory;

public class PredicateUtil {
	
	private static final String DATE_FORMAT = "ddMMyyyy";
	private static final Log4Debug log4Debug = Log4DebugFactory.getLog4Debug(PredicateUtil.class);
	
	/**
	 * checking the Recapiti object is having the given input String as the valore
	 * @param value
	 * @return
	 */
	public static Predicate<Object> checkStringExist (final String value) {
		final Predicate<Object> stringExist = new Predicate<Object>() {
		    public boolean apply(Object object) {
		    	final SoggettoRecapitiView view = (SoggettoRecapitiView) object;
		        return value.equals(view.getValoreRecapiti());
		    }
		};
		return stringExist;
	}
	
	/**
	 * checks the input document is a New Document or not based on Document Id.
	 * @return
	 */
	public static Predicate<Object> newDocumentExist () {
		final Predicate<Object> docExist = new Predicate<Object>() {
		    public boolean apply(Object object) {
		    	final DocumentoPFView view = (DocumentoPFView) object;
		    	boolean result = false;
		    	if(view.getDocumentoId() == null){
		    		result = true;
		    	}
				return result;
		    }
		};
		return docExist;
	}
	
	/**
	 * checks the document is valid and of TypeE Document.
	 * @return
	 */
	public static Predicate<Object> getDocumentOfTypeE () {
		final Predicate<Object> document = new Predicate<Object>() {
		    public boolean apply(Object object) {
		    	final DocumentoPFView view = (DocumentoPFView) object;
		    	final String tipoDocument = view.getTipoDocumento().getCausale();
		    	boolean result = false;
		    	if(view.getDataFineValidita() != null && "RPS".equals(tipoDocument) || "RRPS".equals(tipoDocument) || "CRPS".equals(tipoDocument) || "PS".equals(tipoDocument) || "CS".equals(tipoDocument)) {
		    		result = true;
		    	}
				return result;
		    }
		};
		return document;
	}
	
	/**
	 * checks the document is valid and of Input Type is equal to the Document Type.
	 * @param tipoDocument
	 * @return
	 */
	public static Predicate<Object> getDocumentOfInputType (final String tipoDocument) {
		final Predicate<Object> document = new Predicate<Object>() {
		    public boolean apply(Object object) {
		    	final DocumentoPFView view = (DocumentoPFView) object;
		    	final String documentType = view.getTipoDocumento().getCausale();
		    	boolean result = false;
		    	if(view.getDataFineValidita() != null && documentType.equals(tipoDocument)) {
		    		result = true;
		    	}
				return result;
		    }
		};
		return document;
	}
	
	/**
	 * checks the document is valid and of Input Type is equal to the Document Type.
	 * @param tipoDocument
	 * @return
	 */
	public static Predicate<Object> getDocumentOfInputTipoDoc (final String tipoDocument) {
		final Predicate<Object> document = new Predicate<Object>() {
		    public boolean apply(Object object) {
		    	final DocumentoPFView view = (DocumentoPFView) object;
		    	final String documentType = view.getTipoDocumento().getCausale();
		    	boolean result = false;
		    	if(documentType.equals(tipoDocument)) {
		    		result = true;
		    	}
				return result;
		    }
		};
		return document;
	}
	
	/**
	 * @return
	 */
	public static Predicate<Object> getAllDocumentOfTypeE() {
		final Predicate<Object> document = new Predicate<Object>() {
		    public boolean apply(Object object) {
		    	final DocumentoPFView view = (DocumentoPFView) object;
		    	final String tipoDocument = view.getTipoDocumento().getCausale();
		    	boolean result = false;
		    	if("RPS".equals(tipoDocument) || "RRPS".equals(tipoDocument) || "CRPS".equals(tipoDocument) || "PS".equals(tipoDocument) || "CS".equals(tipoDocument)) {
		    		result = true;
		    	}
				return result;
		    }
		};
		return document;
	}
	
	/**
	 * This Method Checks the given input Dai Weightage (DAIOK, DAIKO, DAIALERT) exist for Regole
	 * @return
	 */
	public static Predicate<IDAIRegoleDetailsView> daiWeightageExist (final String weightage) {
		final Predicate<IDAIRegoleDetailsView> regoleView = new Predicate<IDAIRegoleDetailsView>() {
		    public boolean apply(final IDAIRegoleDetailsView object) {
		    	boolean result = false;
		    	if(object.getDaiWeight() != null && weightage.equals(object.getDaiWeight().getDaiConfigCode())) {
		    		result = true;
		    	}
				return result;
		    }
		};
		return regoleView;
	}
	
	/**
	 * This method checks the Document is of Type A, B or C and Document is Valid.
	 * @return
	 */
	public static Predicate<DocumentoPFView> getTypeABCValidDocuments() {
		final Predicate<DocumentoPFView> document = new Predicate<DocumentoPFView>() {
			public boolean apply(final DocumentoPFView documentView) {
				boolean result = false;
				try {
					String tipoDoc = documentView.getTipoDocumento() != null ? documentView.getTipoDocumento().getCausale() : "";
					log4Debug.debug("tipoDoc  =======================    ",tipoDoc);
					final CompDocumentView comDocumentView = IMFactory.getInstance().getCompatibleDocumentView(tipoDoc, SecurityHandler.getLoginBancaId());
					log4Debug.debug("comDocumentView  =======================    ",comDocumentView);
					log4Debug.debug("DataFine  =======================    ",documentView.getDataFineValidita());
					if (documentView.getDataFineValidita() == null && comDocumentView != null 
							&& ("A".equals(comDocumentView.getDocClass()) || "B".equals(comDocumentView.getDocClass()) || "C".equals(comDocumentView.getDocClass()))
							&& (!"CS".equals(tipoDoc) || isCSDocumentTypeB(tipoDoc, documentView.getDataEmissione()))) {
						result = true;
					}
				} catch (final SubSystemHandlerException e) {
					log4Debug.debugStackTrace(e);
				} catch (final InformazioneManagerException e) {
					log4Debug.debugStackTrace(e);
				} catch (final IMCreationException e) {
					log4Debug.debugStackTrace(e);
				}
				return result;
			}
		};
		return document;
	}
	
	/**
	 * This method checks the Document is of Type A, B or C and Recently Expired (recent expired calaulation using buffer days)
	 * @return
	 */
	public static Predicate<DocumentoPFView> getTypeABCRecentExpiredDocuments() {
		final Predicate<DocumentoPFView> document = new Predicate<DocumentoPFView>() {
			final DateHandler dateHandler = new DateHandler();
			public boolean apply(final DocumentoPFView documentView) {
				boolean result = false;
				try {
					String tipoDoc = documentView.getTipoDocumento() != null ? documentView.getTipoDocumento().getCausale() : "";
					final CompDocumentView comDocumentView = IMFactory.getInstance().getCompatibleDocumentView(tipoDoc, SecurityHandler.getLoginBancaId());
					Timestamp currentDate = dateHandler.getTimestampFromDateString(dateHandler.formatDate(dateHandler.getCurrentDateInTimeStampFormat(),DATE_FORMAT), DATE_FORMAT);
					final int bufferDays = (comDocumentView != null && comDocumentView.getValidBufferDays() != null) ? comDocumentView.getValidBufferDays().intValue() : 0;
					currentDate = dateHandler.getTimeStampSpecifiedDay(currentDate, -bufferDays);
					final Timestamp dataScadenza = (documentView.getDataScadenza() == null && "CS".equals(tipoDoc)) ? (dateHandler.getTimeStampSpecifiedYear(documentView.getDataEmissione(),5)) : documentView.getDataScadenza();
					
					if ((documentView.getDataFineValidita() != null || ("CS".equals(tipoDoc) && new DateHandler().isDateMoreThanSpecifiedYears(documentView.getDataEmissione(),5))) && comDocumentView != null 
							&& ("A".equals(comDocumentView.getDocClass()) || "B".equals(comDocumentView.getDocClass()) || "C".equals(comDocumentView.getDocClass()))
							&& dataScadenza != null && dataScadenza.compareTo(currentDate) > 0) {
						result = true;
					}
				} catch (final SubSystemHandlerException e) {
					log4Debug.debugStackTrace(e);
				} catch (final InformazioneManagerException e) {
					log4Debug.debugStackTrace(e);
				} catch (final IMCreationException e) {
					log4Debug.debugStackTrace(e);
				} catch (final HelperException e) {
					log4Debug.debugStackTrace(e);
				}
				return result;
			}
		};
		return document;
	}
	
	/**
	 * This method checks the Document is of Type E Valid documents
	 * @return
	 */
	public static Predicate<DocumentoPFView> getTypeEValidDocuments() {
		final Predicate<DocumentoPFView> document = new Predicate<DocumentoPFView>() {
			public boolean apply(final DocumentoPFView documentView) {
				boolean result = false;
				try {
					String tipoDoc = documentView.getTipoDocumento() != null ? documentView.getTipoDocumento().getCausale() : "";
					final CompDocumentView comDocumentView = IMFactory.getInstance().getCompatibleDocumentView(tipoDoc, SecurityHandler.getLoginBancaId());
					if(documentView.getDataFineValidita() == null && ((comDocumentView != null && "E".equals(comDocumentView.getDocClass())) || ("CS".equals(tipoDoc) /*&& new DateHandler().isDateMoreThanSpecifiedYears(documentView.getDataEmissione(),5) */))) {
						result = true;
					}
				} catch (final SubSystemHandlerException e) {
					log4Debug.debugStackTrace(e);
				} catch (final InformazioneManagerException e) {
					log4Debug.debugStackTrace(e);
				} catch (final IMCreationException e) {
					log4Debug.debugStackTrace(e);
				}
				return result;
			}
		};
		return document;
	}
	
	/**
	 * This method checks the Document is of Type E and Recently Expired (recent expired calaulation using buffer days)
	 * @return
	 */
	public static Predicate<DocumentoPFView> getTypeERecentExpiredDocuments() {
		final Predicate<DocumentoPFView> document = new Predicate<DocumentoPFView>() {
			final DateHandler dateHandler = new DateHandler();
			public boolean apply(final DocumentoPFView documentView) {
				boolean result = false;
				try {
					String tipoDoc = documentView.getTipoDocumento() != null ? documentView.getTipoDocumento().getCausale() : "";
					final CompDocumentView comDocumentView = IMFactory.getInstance().getCompatibleDocumentView(tipoDoc, SecurityHandler.getLoginBancaId());
					Timestamp currentDate = dateHandler.getTimestampFromDateString(dateHandler.formatDate(dateHandler.getCurrentDateInTimeStampFormat(),DATE_FORMAT), DATE_FORMAT);
					final int bufferDays = (comDocumentView != null && comDocumentView.getValidBufferDays() != null) ? comDocumentView.getValidBufferDays().intValue() : 0;
					currentDate = dateHandler.getTimeStampSpecifiedDay(currentDate,-bufferDays);
					if (documentView.getDataFineValidita() != null && ((comDocumentView != null && "E".equals(comDocumentView.getDocClass())) || ("CS".equals(tipoDoc) && new DateHandler().isDateMoreThanSpecifiedYears(documentView.getDataEmissione(),5) ))
							&& documentView.getDataScadenza() != null && documentView.getDataScadenza().compareTo(currentDate) > 0) {
						result = true;
					}
				} catch (final SubSystemHandlerException e) {
					log4Debug.debugStackTrace(e);
				} catch (final InformazioneManagerException e) {
					log4Debug.debugStackTrace(e);
				} catch (final IMCreationException e) {
					log4Debug.debugStackTrace(e);
				} catch (final HelperException e) {
					log4Debug.debugStackTrace(e);
				}
				return result;
			}
		};
		return document;
	}
	
	private static boolean isCSDocumentTypeB (final String tipoDocCausale, final Timestamp dataEmissione) {
		boolean result = false;
		if("CS".equals(tipoDocCausale) && dataEmissione != null && !new DateHandler().isDateMoreThanSpecifiedYears(dataEmissione,5)) {
			result = true;
		}
		return result;
	}
	
	public static Predicate<DocumentoPFView> getTypeABCINValidDocuments() {
		final Predicate<DocumentoPFView> document = new Predicate<DocumentoPFView>() {
			public boolean apply(final DocumentoPFView documentView) {
				boolean result = false;
				try {
					String tipoDoc = documentView.getTipoDocumento() != null ? documentView.getTipoDocumento().getCausale() : "";
					final CompDocumentView comDocumentView = IMFactory.getInstance().getCompatibleDocumentView(tipoDoc, SecurityHandler.getLoginBancaId());
					
					if((documentView.getDataFineValidita() != null || ("CS".equals(tipoDoc) && new DateHandler().isDateMoreThanSpecifiedYears(documentView.getDataEmissione(),5))) && comDocumentView != null
							&& ("A".equals(comDocumentView.getDocClass()) || "B".equals(comDocumentView.getDocClass()) || "C".equals(comDocumentView.getDocClass()))) {
						result = true;
					}
				} catch (final SubSystemHandlerException e) {
					log4Debug.debugStackTrace(e);
				} catch (final InformazioneManagerException e) {
					log4Debug.debugStackTrace(e);
				} catch (final IMCreationException e) {
					log4Debug.debugStackTrace(e);
				}
				return result;
			}
		};
		return document;
	}
	
	/**
	 * This method checks the Document is of Type E Valid documents
	 * @return
	 */
	public static Predicate<DocumentoPFView> getTypeEINValidDocuments() {
		final Predicate<DocumentoPFView> document = new Predicate<DocumentoPFView>() {
			public boolean apply(final DocumentoPFView documentView) {
				boolean result = false;
				try {
					String tipoDoc = documentView.getTipoDocumento() != null ? documentView.getTipoDocumento().getCausale() : "";
					final CompDocumentView comDocumentView = IMFactory.getInstance().getCompatibleDocumentView(tipoDoc, SecurityHandler.getLoginBancaId());
					if(documentView.getDataFineValidita() != null && ((comDocumentView != null && "E".equals(comDocumentView.getDocClass())) || ("CS".equals(tipoDoc) /*&& new DateHandler().isDateMoreThanSpecifiedYears(documentView.getDataEmissione(),5) */))) {
						result = true;
					}
				} catch (final SubSystemHandlerException e) {
					log4Debug.debugStackTrace(e);
				} catch (final InformazioneManagerException e) {
					log4Debug.debugStackTrace(e);
				} catch (final IMCreationException e) {
					log4Debug.debugStackTrace(e);
				}
				return result;
			}
		};
		return document;
	}
	
	/*private static Timestamp getComparistionDate () {
		final DateHandler dateHandler = new DateHandler();
		Timestamp comaprisionDate = null;
		try {
			comaprisionDate =  dateHandler.getTimestampFromDateString("20/12/9999", "dd/MM/yyyy");
		} catch (HelperException e) {
			log4Debug.debug(e);
		}
		return comaprisionDate;
	}*/
}
