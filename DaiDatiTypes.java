package it.sella.anagrafe.dai;

import it.sella.anagrafe.AnagrafeDAIException;
import it.sella.anagrafe.DAIRegoleDetailsView;
import it.sella.anagrafe.IDAIConfigView;
import it.sella.anagrafe.IDAIRegoleDetailsView;
import it.sella.anagrafe.service.InvocationHandler;
import it.sella.anagrafe.soaservices.exception.AnagrafeServiceException;
import it.sella.anagrafe.util.AnagrafeHelper;
import it.sella.anagrafe.view.SoggettoView;
import it.sella.util.Log4Debug;
import it.sella.util.Log4DebugFactory;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.Set;

/**
 * @author GBS03447
 * This Enum Class represents Values which has taken from AN_MA_DAI_CONFIG With Parent as DAI_DATI.
 * When Any New Group Added For Regole Calculation.. The Added group should Add here .. and Process for regole calculation.
 * Or If any change in Group Name also we need to change the corresponding Enum value.
 *
 */
public enum DaiDatiTypes {
	
	DatiAnagraficiPF {

		@Override
		public Collection<IDAIRegoleDetailsView> processDaiCalculation(final Collection<IDAIConfigView> daiRegoleList, final SoggettoView soggettoView) throws AnagrafeDAIException {
			return doDaiCodeValidationAndBuildRegole(daiRegoleList, soggettoView, this.name());
		}
	},
	
	Residenza {

		@Override
		public Collection<IDAIRegoleDetailsView> processDaiCalculation(final Collection<IDAIConfigView> daiRegoleList, final SoggettoView soggettoView) throws AnagrafeDAIException {
			return doDaiCodeValidationAndBuildRegole(daiRegoleList, soggettoView, this.name());
		}
		
	},
	
	Domicilio {

		@Override
		public Collection<IDAIRegoleDetailsView> processDaiCalculation(final Collection<IDAIConfigView> daiRegoleList, final SoggettoView soggettoView) throws AnagrafeDAIException {
			return doDaiCodeValidationAndBuildRegole(daiRegoleList, soggettoView, this.name());
		}
		
	},
	
	AltriDocumenti {
		@Override
		public Collection<IDAIRegoleDetailsView> processDaiCalculation(final Collection<IDAIConfigView> daiRegoleList, final SoggettoView soggettoView) throws AnagrafeDAIException {
			return doDaiCodeValidationAndBuildRegole(daiRegoleList, soggettoView, this.name());
		}
	},
	
	Datifiscali {
		
		@Override
		public Collection<IDAIRegoleDetailsView> processDaiCalculation(final Collection<IDAIConfigView> daiRegoleList, final SoggettoView soggettoView) throws AnagrafeDAIException {
			return doDaiCodeValidationAndBuildRegole(daiRegoleList, soggettoView, this.name());
		}
	},
	
	Attributi {
		
		@Override
		public Collection<IDAIRegoleDetailsView> processDaiCalculation(final Collection<IDAIConfigView> daiRegoleList, final SoggettoView soggettoView) throws AnagrafeDAIException {
			return doDaiCodeValidationAndBuildRegole(daiRegoleList, soggettoView, this.name());
		}
	}, 
	
	DocumentiANTCI {
		@Override
		public Collection<IDAIRegoleDetailsView> processDaiCalculation(final Collection<IDAIConfigView> daiRegoleList, final SoggettoView soggettoView) throws AnagrafeDAIException {
			return doDaiCodeValidationAndBuildRegole(daiRegoleList, soggettoView, this.name());
		}
	},
	
	SedeLegale {
		@Override
		public Collection<IDAIRegoleDetailsView> processDaiCalculation(final Collection<IDAIConfigView> daiRegoleList, final SoggettoView soggettoView) throws AnagrafeDAIException {
			return doDaiCodeValidationAndBuildRegole(daiRegoleList, soggettoView, this.name());
		}
	},
	SedeAmministrativa {
		@Override
		public Collection<IDAIRegoleDetailsView> processDaiCalculation(final Collection<IDAIConfigView> daiRegoleList, final SoggettoView soggettoView) throws AnagrafeDAIException {
			return doDaiCodeValidationAndBuildRegole(daiRegoleList, soggettoView, this.name());
		}
	};
	
	private static final Log4Debug log4Debug = Log4DebugFactory.getLog4Debug(DaiDatiTypes.class);
	public abstract Collection<IDAIRegoleDetailsView> processDaiCalculation(final Collection<IDAIConfigView> daiRegoleList, final SoggettoView soggettoView) throws AnagrafeDAIException;	
	private final static Set<String> values = getValues();
    
	private static Set<String> getValues() {
		final Set<String> values = new HashSet<String>(DaiDatiTypes.values().length);
		for(final DaiDatiTypes value: DaiDatiTypes.values()) {
        	values.add(value.name());
        }
		return values;
	}
    
    public static boolean contains(final String value ){
        return values.contains(value);
    }
    
    
    /**
     * @param daiRegoleList
     * @param soggettoView
     * @param daiDatiType
     * @return
     * @throws AnagrafeDAIException
     */
    private static final Collection<IDAIRegoleDetailsView> doDaiCodeValidationAndBuildRegole (final Collection<IDAIConfigView> daiRegoleList, final SoggettoView soggettoView, final String daiDatiType) throws AnagrafeDAIException {
    	log4Debug.debug("DaiDatiTypes        ::::      doDaiCodeValidationAndBuildRegole      :::    processing   daiDatiType  ::   ", daiDatiType);
    	final Collection<IDAIRegoleDetailsView> regoleDetailsList = new ArrayList<IDAIRegoleDetailsView>();
    	final Class<?>[] paramType = new Class[]{SoggettoView.class, String.class, Long.class};
    	
		for (final IDAIConfigView daiConfigView : daiRegoleList) {
			final Object[] paramValue = new Object[]{soggettoView, daiDatiType, daiConfigView.getDaiConfigId()};
			try{
				final String methodName = DaiRegoleCodes.valueOf(daiConfigView.getDaiConfigCode()).getMethodName();
				final Class<?> clazzName = DaiRegoleCodes.valueOf(daiConfigView.getDaiConfigCode()).getClazzName();
				if(methodName != null && clazzName != null) {
					final DAIRegoleDetailsView regoleDetailsView = (DAIRegoleDetailsView) new InvocationHandler().executeService(clazzName, methodName, paramType, paramValue);
					AnagrafeHelper.isNotNullAddToCollection(regoleDetailsList, regoleDetailsView);
				}
			}catch (final IllegalArgumentException e) { // Get Confirmation
				log4Debug.debug("IllegalArgumentException  =========   Method Or Class Name Found For daiDatiType  ====  ",daiConfigView.getDaiConfigCode());
				log4Debug.debugStackTrace(e);
			}catch (final AnagrafeServiceException e) {
				log4Debug.debugStackTrace(e);
				throw new AnagrafeDAIException(e.getMessage(), e);
			}
		}
		return regoleDetailsList;
    }
}
