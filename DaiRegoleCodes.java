package it.sella.anagrafe.dai;

import it.sella.anagrafe.validator.DaiAttributiFiscaliValidator;
import it.sella.anagrafe.validator.DaiDatiAnagrafeValidator;
import it.sella.anagrafe.validator.DaiDocumentiValidator;
import it.sella.anagrafe.validator.DaiIndirizziAZValidator;
import it.sella.anagrafe.validator.DaiIndirizziValidator;

/**
 * @author GBS03447
 * This Enum Has Values From AN_MA_DAI_CONFIG table. If any change in Regole Name in table .. the same has to change here.
 * If any new Regole added and to calculate weightage the same regole has to add here with validation class and method .
 */
public enum DaiRegoleCodes {

	DAIPFNomeCognome("validateNomeAndCogNome", DaiDatiAnagrafeValidator.class), 
	DAIPFDOB("validateDOB", DaiDatiAnagrafeValidator.class), 
	DAIPFNOB("validateNazioneOfBirth", DaiDatiAnagrafeValidator.class), 
	DAIPFCOB("validatecittaOfBirth", DaiDatiAnagrafeValidator.class),	
	DAIPFAECIT("validateCittadenza", DaiAttributiFiscaliValidator.class),
	DAIPFIREIND("validateIREIndirizzi", DaiIndirizziValidator.class),
	DAIPFIRECIT("validateIREIndirizziCitta", DaiIndirizziValidator.class),
	DAIPFIRENAZ("validateIREIndirizziNazione", DaiIndirizziValidator.class),
	DAIPFIREPRO("validateIREIndirizziProvincia", DaiIndirizziValidator.class),	
	DAIPFIRECPR("validateIREIndirizziCittaProvincia", DaiIndirizziValidator.class),
	DAIIDOIND("validateIDOIndirizzi", DaiIndirizziValidator.class),
	DAIIDOCIT("validateIDOIndirizziCitta", DaiIndirizziValidator.class),
	DAIIDONAZ("validateIDOIndirizziNazione", DaiIndirizziValidator.class),
	DAIIDOPRO("validateIDOIndirizziProvincia", DaiIndirizziValidator.class),
	DAIIDOCPR("validateIDOIndirizziCittaProvincia", DaiIndirizziValidator.class),
	DAIPFCF("validatePFCodiceFiscale", DaiAttributiFiscaliValidator.class),
	DAIPFAEPRO("validatePFProfessione", DaiAttributiFiscaliValidator.class),
	DAIPFAETAE("validatePFTAE", DaiAttributiFiscaliValidator.class),
	DAIAZCF("validateAZCodiceFiscale", DaiAttributiFiscaliValidator.class),
	DAIAZCFEST("validateAZCodiceFiscaleEstero", DaiAttributiFiscaliValidator.class),
	DAIAZPIVA("validateAZPartitaIVA", DaiAttributiFiscaliValidator.class),
	DAIAZSET("validateAZSettore", DaiAttributiFiscaliValidator.class),
	DAIAZATE("validateAZAteco", DaiAttributiFiscaliValidator.class),
	DAIPFANTCI("validatePFDocumentANTCI", DaiDocumentiValidator.class),
	DAIPFAGGIU("validatePFDocumentAGGI", DaiDocumentiValidator.class),	
	DAIAZSLEIND("validateSLEIndirizzi", DaiIndirizziAZValidator.class),
	DAIAZSLECIT("validateSLEIndirizziCitta", DaiIndirizziAZValidator.class),
	DAIAZSLENAZ("validateSLEIndirizziNazione", DaiIndirizziAZValidator.class),
	DAIAZSLEPRO("validateSLEIndirizziProvincia", DaiIndirizziAZValidator.class),	
	DAIAZSLECPR("validateSLEIndirizziCittaProvincia", DaiIndirizziAZValidator.class),
	DAIAZSAMIND("validateSAMIndirizzi", DaiIndirizziAZValidator.class),
	DAIAZSAMCIT("validateSAMIndirizziCitta", DaiIndirizziAZValidator.class),
	DAIAZSAMNAZ("validateSAMIndirizziNazione", DaiIndirizziAZValidator.class),
	DAIAZSAMPRO("validateSAMIndirizziProvincia", DaiIndirizziAZValidator.class),	
	DAIAZSAMCPR("validateSAMIndirizziCittaProvincia", DaiIndirizziAZValidator.class);
	
	
	private String methodName;
	private Class<?> clazzName;
	
	/**
	 * @param methodName
	 * @param clazzName
	 */
	private DaiRegoleCodes(final String methodName, final Class<?> clazzName) {
		this.setClazzName(clazzName);
		this.setMethodName(methodName);
	}

	public void setMethodName(final String methodName) {
		this.methodName = methodName;
	}

	public String getMethodName() {
		return methodName;
	}
	
	public void setClazzName(final Class<?> clazzName) {
		this.clazzName = clazzName;
	}

	public Class<?> getClazzName() {
		return clazzName;
	}
}
