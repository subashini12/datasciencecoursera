package it.sella.anagrafe.soaservices.ise.customer;

import it.sella.anagrafe.soaservices.exception.AnagrafeServiceException;
import it.sella.anagrafe.soaservices.services.CustomerService;
import it.sella.integrazione_sistemi_esterni.ServiceException;
import it.sella.integrazione_sistemi_esterni.server.Bridge;
import it.sella.util.Log4Debug;
import it.sella.util.Log4DebugFactory;

import java.rmi.RemoteException;

public class CreateMINMLCustomerBridge implements Bridge {
	
	private static final Log4Debug log4Debug =Log4DebugFactory.getLog4Debug(CreateMINMLCustomerBridge.class);
	
	@Override
	public String invokeService(final String soaAnagInputXml) throws ServiceException, RemoteException {
		try {
			log4Debug.debug("CustomerMinmlBridge : invokeService : inputXML : ", soaAnagInputXml);
			final String soaAnagOutputXml = new CustomerService().createMinmlCustomer(soaAnagInputXml);
			log4Debug.debug("CustomerMinmlBridge : invokeService : outputXML : ", soaAnagOutputXml);
			return soaAnagOutputXml;
		} catch (final AnagrafeServiceException e) {
			log4Debug.severe(e.getMessage());
			throw new ServiceException("KO " + e.getMessage());
		}
	}
}
