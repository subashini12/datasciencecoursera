package it.sella.anagrafe.util;

import it.sella.util.Log4Debug;
import it.sella.util.Log4DebugFactory;

import java.util.regex.Pattern;

import org.apache.commons.lang.StringEscapeUtils;

/**
 *  This class has the methods to validate strings
 */

public class StringHandler extends StringTokenHandler {
	
	private static final Log4Debug log4Debug = Log4DebugFactory.getLog4Debug(StringHandler.class);

	
	public static String encodeXMLTagValue( final String data ){
		//return data != null ?  new StringBuffer("<![CDATA[").append(data).append("]]>").toString() : "" ;
		return StringEscapeUtils.escapeXml(data); 
	}
	
	/** This method checks whether any " is there and replaces this character with
    two '
    @ return String " replaced with '
    */
	
	public String replaceDoubleQuotes( final String data ) {
        char extrchar;
        final StringBuffer replaceData = new StringBuffer();
        if (data != null) {
	        for(int i = 0; i < data.length(); i++) {
	            extrchar = data.charAt(i);
				replaceData.append(extrchar == '\"' ? "''" : String.valueOf(extrchar));
	        }
        }
        return replaceData.toString();
    }
	/**
	 * This method checks for any "," from the input string and replaces it with space
	 * @param data
	 * @return
	 */

	public String replaceCommaWithSpace(final String data){
		final StringBuffer replaceData = new StringBuffer();
		replaceData.append(data.replaceAll("(,)", " "));

		log4Debug.info("replaceData=======================",replaceData);
		return replaceData.toString();
	}

	/**
	 * This method checks for Special Characters | and § from the input String and replace it with space
	 * @param data
	 * @return
	 */

	public String replaceSpecialCharacterWithSpace(final String data){
		//final String data1 = "[|]";
		final StringBuffer replaceData = new StringBuffer();
		replaceData.append(data.replaceAll("[(|)||(§)]"," "));
		log4Debug.info("replaceSpecialCharacterWithSpace=======================",replaceData);
		return replaceData.toString();
	}

	/** This method checks whether any ' is there and replaces this character with
    two '
    @ return String ' replaced with ''
    */

	public String addSingleQuotes( final String data ) {
        char extrchar;
        final StringBuffer replaceData = new StringBuffer();
        for(int i = 0; i < data.length(); i++) {
            extrchar = data.charAt(i);
			replaceData.append(extrchar == '\'' ? "''" : String.valueOf(extrchar));
        }
        return replaceData.toString();
    }

   /** This method checks whether any ' is there and removes this character with '
    @ param String Data which contains characters
    @ param
    @ return String ' replaced with '
    */

	public String removeSpecifiedData( String data ) {
		String result = null;
        if(data != null) {
			data = data.replace('À','A').replace('Á','A').replace('à','A').replace('á','A');
			data = data.replace('È','E').replace('É','E').replace('è','E').replace('é','E');
			data = data.replace('Ì','I').replace('Í','I').replace('ì','I').replace('í','I');
			data = data.replace('Ò','O').replace('Ó','O').replace('ò','O').replace('ó','O');
			data = data.replace('Ù','U').replace('Ú','U').replace('ù','U').replace('ú','U');
            char extrchar;
            final StringBuffer replaceData = new StringBuffer();
			final int size = data.length();
			for(int i = 0; i < size; i++) {
                extrchar = data.charAt(i);
                if(!Character.isWhitespace(extrchar) && Character.isLetter(extrchar)) {
					replaceData.append(extrchar);
				}
            }
			result = replaceData.toString();
        }
		return result;
	}
	
	public String removeSpecificChar( String data ) {
		String result = null;
        if(data != null) {
			data = data.replace('À','A').replace('Á','A').replace('à','A').replace('á','A');
			data = data.replace('È','E').replace('É','E').replace('è','E').replace('é','E');
			data = data.replace('Ì','I').replace('Í','I').replace('ì','I').replace('í','I');
			data = data.replace('Ò','O').replace('Ó','O').replace('ò','O').replace('ó','O');
			data = data.replace('Ù','U').replace('Ú','U').replace('ù','U').replace('ú','U');
			result = data;
        }
		return result;
	}

   /** This checks whether any special character is available in the data
    @ param String data
    @ return boolean
    */

   public boolean isExistsSplChars( final String inputValue ) {
	   if(inputValue != null) {
	       char extrchar;
	       for( int i = 0; i < inputValue.length(); i++ ) {
	           extrchar = inputValue.charAt(i);
	           if(!Character.isLetter(extrchar) && !Character.isWhitespace(extrchar) && !"'".equals(String.valueOf(extrchar))) {
	               return true;
	           }
	       }
	   }
       return false;
   }


   /** This checks whether any special character is available in the data and even
    * if the special characters are available it sees whether that special characters
    * can be excluded while checking for the jolly characters
    @ param String data
    @ param character array
    @ return boolean
    */

   public boolean isExistsSpecifiedChars( final String inputValue, final char notAllowed [] ) {
	   if(inputValue != null) {
		   final int length = notAllowed.length;
		   for(int j=0; j<length; j++) {
			   if(inputValue.indexOf(notAllowed[j]) != -1) {
				return true;
			}
		   }
       }
	   return false;
   }

   
   /** This method removes all the special characters and returns a normalised string
    * @ param String
    * @ return String normalised string
    */
   
   public String getNormalisedString( final String unnormalisedString ) {
	   String normalizedString = null;
	   if( unnormalisedString != null ) {
    	   normalizedString = getNormalizedStringForNomeAndCognome(unnormalisedString);
		}
       return normalizedString;
   }
   
   public String getNormalizedStringForNomeAndCognome( final String name ) {
		StringBuffer buffer = new StringBuffer();
		int size = name.length();
		for( int i=0; i<size; buffer.append(Character.isLetter(name.charAt(i)) && name.charAt(i) != 'H' ? String.valueOf(name.charAt(i)) : ""),i++) {
			;
		}
       String temp = buffer.toString().toUpperCase();
		temp = temp.replace('K','C').replace('W','V').replace('J','I').replace('Y','I');
		temp = temp.replace('À','A').replace('Á','A').replace('à','A').replace('á','A');
		temp = temp.replace('È','E').replace('É','E').replace('è','E').replace('é','E');
		temp = temp.replace('Ì','I').replace('Í','I').replace('ì','I').replace('í','I');
		temp = temp.replace('Ò','O').replace('Ó','O').replace('ò','O').replace('ó','O');
		temp = temp.replace('Ù','U').replace('Ú','U').replace('ù','U').replace('ú','U');
		buffer = new StringBuffer(temp);
		replaceSpecifiedValues(buffer,"GG","G");
		replaceSpecifiedValues(buffer,"QU","C");
		replaceSpecifiedValues(buffer,"GN","N");
		temp = buffer.toString();
		buffer = new StringBuffer();
		size = temp.length();
		char ch =' ';
		for(int i=0; i<size; i++) {
			if(i == 0 || temp.charAt(i) != ch) {
				buffer.append(temp.charAt(i));
			}
		    ch = temp.charAt(i);
		}
		return buffer.toString();
   }

   public  void validateStringForSameChar( final String input ) throws HelperException {
       if(input != null && input.length() > 0) {
           final int size = input.length() > 5 ? 5 : input.length();
           final char ch = input.charAt(0);
           for( int j = 1; j < size; j++ ) {
        	   if( ch != input.charAt(j) ) {
        		   break;
        	   } else if( j == (size - 1) ) {
					throw new HelperException();
        	   }
       	   }
		}
   }

   public String removeSingleQuote( final String input ) {
       final StringBuffer output = new StringBuffer();
       if( input != null ) {
           final int size = input.length();
           for(int i = 0; i < size; i++) {
				final String character = String.valueOf(input.charAt(i));
				output.append(!"'".equals(character) ? character : "");
           }
       }
       return output.toString();
   }

   public boolean checkForEquality(final Object oldValue, final Object newValue) {
	   boolean checkForEquality = true;
	   if (oldValue != null && newValue != null) {
		   checkForEquality = oldValue.equals(newValue);
		} else if (oldValue != null || newValue != null) {
			checkForEquality = false;
		}
	   return checkForEquality;
	}
   
   /*
	 * private void replaceSpecifiedValues(StringBuffer input,String
	 * toBeRemoved, String toReplace) { int index =
	 * input.toString().indexOf(toBeRemoved); if(index != -1)
	 * input.replace(index,index+2,toReplace); }
	 */
   
   private static void replaceSpecifiedValues( final StringBuffer input, final String toBeRemoved, final String toReplace ) {
	   int index = input.toString().indexOf(toBeRemoved);
	   while(index != -1) {
			input.replace(index,index+2,toReplace);
			index = input.toString().indexOf(toBeRemoved);
	   }
	}
   
   public boolean isEmpty( final String fieldValue ) {
	   boolean isValid = false;
	   if( fieldValue == null || fieldValue.trim().length() < 1 ) {
		   isValid = true;
	   }		
	   return isValid;
	}
   
   public  boolean isNumeric( final String input ) {
	   boolean isValid = false;
		try {
			Integer.valueOf(input) ;
			isValid = true;	
		} catch (final NumberFormatException e) {
			log4Debug.warnStackTrace(e);
		}
		return isValid;
	}
   
   public static Long getLongValue( final String fieldValue ) {
	   Long result = null;
	   if( fieldValue != null && fieldValue.trim().length() >= 1 ) {
		   result = Long.valueOf(fieldValue.trim());
	   } 
	   return result;
   }
   
   public  boolean isDouble( final String input ) {
	    boolean isValid = false;
		try {
			Double.valueOf(input);
			isValid = true;	
		} catch (final NumberFormatException e) {
			log4Debug.warnStackTrace(e);
		}		
		return isValid;
	}
   
   public boolean isNumericCharExistMoreThanSpecifiedLength( final String cittaCommune, final int noOfElements ) {
		boolean result = false;
		if ( cittaCommune != null && cittaCommune.trim().length() > 0 ) {
			final String cittaString = cittaCommune.trim();
			final int size = cittaString.length();
			final StringBuffer numericBuffer = new StringBuffer();
			char cittaChar;
			for ( int i=0; i<size; i++  ) {
				cittaChar = cittaString.charAt(i);
				try {
						Long.valueOf(String.valueOf(cittaChar));
						numericBuffer.append(cittaChar);
				} catch ( final Exception e ) {
					log4Debug.debugStackTrace(e);
				}
			}
			if( numericBuffer.length() > noOfElements ) {
				result = true;
			}
		}   	
		return result;
   }

   public boolean isConsequentCharsSame( final String cittaCommune ) {
	   boolean isValid = false;
	   if ( cittaCommune != null && cittaCommune.trim().length() > 0 ) {
		   final String regEx = "((a{4}|b{4}|c{4}|d{4}|e{4}|f{4}|g{4}|h{4}|i{4}|j{4}|k{4}|l{4}|m{4}|n{4}|o{4}|p{4}|q{4}|r{4}|s{4}|t{4}|u{4}|v{4}|w{4}|x{4}|y{4}|z{4}|A{4}|B{4}|C{4}|D{4}|E{4}|F{4}|G{4}|H{4}|I{4}|J{4}|K{4}|L{4}|M{4}|N{4}|O{4}|P{4}|Q{4}|R{4}|S{4}|T{4}|U{4}|V{4}|W{4}|X{4}|Y{4}|Z{4}))";
		   final Pattern pattern =  Pattern.compile(regEx);
		   isValid = pattern.matcher(cittaCommune.trim()).find();
	   }   	
	   return isValid;
   }
   

   /**
    * Method to find Pattern Matches
    * @param regExpression
    * @param value
    * @return
    */
   public boolean isPatternMatches(final String regExpression, final String value)
   {
	   final Pattern pattern = Pattern.compile(regExpression);
	   return pattern.matcher(value).find();
   }
   

   public boolean isLengthLessThanSpecifiedMinLength( final String value, final int minLength ) {
	boolean isValid = false;
   	if ( value != null && value.trim().length() > 0 && value.trim().length() < minLength ) {
   		isValid = true;
   	}   	
	return isValid;
   }

   public boolean checkisNotEmpty (final Object objValue ) {
		boolean isValid = false;
		if ( objValue != null && !"".equals(objValue.toString().trim()) ) {
			isValid = true;
		}
		return isValid;
	}

   public String constructDate(final String day,final String month,final String year) {
		String riffDate= null;
		if ( day!= null && month!= null && year!= null ){
			riffDate =  day+"/"+month+"/"+year;
			log4Debug.debug( "Entered riffDate ...",riffDate );
		}
		return riffDate;
	}

   public static String escapeXMLTagValue( final String data ){
		return StringEscapeUtils.unescapeXml(data);
	}
   
   public boolean isExistsSpecifiedLength(final String data, final int length){
	   boolean isValid = false;
	   if(data!=null){
		   isValid = ( data.length()>length ? Boolean.TRUE : Boolean.FALSE );
	   }
	   return isValid;
   }
   
   /**
	 * @param inputData
	 */
	public static boolean validateAlphaNumeric(final String inputData) {
		boolean isValid = true;
		final Pattern pattern = Pattern.compile("(?!^[0-9]*$)(?!^[a-zA-Z]*$)^([a-zA-Z0-9]{1,50})$");
		if(!pattern.matcher(inputData).matches()){
			isValid = false;
		}		
		return isValid;
	}
	
	public static String[] getValueAfterSplitting(final String value){
		String[]valueAfterSpliting = {};
		if(value != null && !"".equals(value) ){
			valueAfterSpliting = value.split("-");
		}
		return valueAfterSpliting;
	}
	
	public static String getUpperCase( final String fieldValue ) {
		   String result = null;
		   if( fieldValue != null && fieldValue.trim().length() > 0 ) {
			   result = fieldValue.trim().toUpperCase();
		   } 
		   return result;
	   }
}
