package it.sella.anagrafe.util;

import it.sella.calendar.DefaultCalendarFactory;
import it.sella.util.Log4Debug;
import it.sella.util.Log4DebugFactory;

import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;
import java.util.StringTokenizer;

public class DateHandler {
	
	private static final Log4Debug log4Debug = Log4DebugFactory.getLog4Debug(DateHandler.class);

	public boolean isDateMoreThanSpecifiedYears( final Timestamp dateToCheck, final int noOfYears ) {
		/*SimpleDateFormat simpleDateFormat = new SimpleDateFormat("dd-MM-yyyy");
		int currentDate = 0;
		int currentMonth = 0;
		int currentYear = 0;
		int inputDate = 0;
		int inputMonth = 0;
		int inputYear = 0;

		String dateString = "";
		StringTokenizer tokenizer = null;
		if ( dateToCheck != null ) {
			dateString = simpleDateFormat.format(dateToCheck);
			tokenizer = new StringTokenizer(dateString, "-");
			inputDate = Integer.parseInt(tokenizer.nextToken().trim());
			inputMonth = Integer.parseInt(tokenizer.nextToken().trim());
			inputYear = Integer.parseInt(tokenizer.nextToken().trim());
		}
		dateString = simpleDateFormat.format(new Date());
		tokenizer = new StringTokenizer(dateString, "-");
		currentDate = Integer.parseInt(tokenizer.nextToken().trim());
		currentMonth = Integer.parseInt(tokenizer.nextToken().trim());
		currentYear = Integer.parseInt(tokenizer.nextToken().trim());
		
		
		
		if( (currentYear - inputYear) > noOfYears ) {
			return true;
		} else if((currentYear - inputYear) == noOfYears && (currentMonth > inputMonth || 
				   (currentMonth == inputMonth && currentDate > inputDate))) {
			return true;
		}*/
		boolean isValid = false;
		try {
			final Calendar calculatedDate = Calendar.getInstance();
			calculatedDate.setTimeInMillis(dateToCheck.getTime());
			calculatedDate.add(calculatedDate.YEAR , noOfYears);
			
			final Timestamp sysDate = getTimestampFromDateString(formatDate(getCurrentDateInTimeStampFormat(), "dd/MM/yyyy"), "dd/MM/yyyy");
			final Calendar currentDate = Calendar.getInstance();
			currentDate.setTimeInMillis(sysDate.getTime());
			
			if (calculatedDate.compareTo(currentDate) <= 0) {
				isValid = true;
			}
		} catch (final HelperException e) {
			//Since previous isDateMoreThanSpecifiedYears not throwing error,so this method exception suppressed 
			log4Debug.debugStackTrace(e);
		}		
		return isValid;
	}
	
    /** fomat Date method formats the date and returns the date as specified in
     * the pattern
     @ param Timestamp dateToformat
     @ param String pattern
     @ return String
     */

    public String formatDate( final Timestamp dateToConvert, final String pattern ) {
        String formattedDate = null;
        if( dateToConvert != null && pattern != null ) {
            formattedDate = new SimpleDateFormat(pattern).format(dateToConvert);
        }
        return formattedDate;
    }

    /** This method creates the timestamp object with the date value and pattern
     * passed to this function
     @ param String date
     @ param String pattern
     @ return Timestamp
     @ exception HelperException
     */

    public Timestamp getTimestampFromDateString( final String date, final String pattern ) throws HelperException {
        Date tempDate = null;
        Timestamp retTimestamp;
        char datechar;
        char patternchar;
        String dateextrchar = null;
        String patternextrchar = null;
        final AnagrafeHelper helper = new AnagrafeHelper();
        try {
        	final SimpleDateFormat dateFormat = new SimpleDateFormat(pattern);
            dateFormat.setLenient(false);
            tempDate = dateFormat.parse(date);
            retTimestamp = new Timestamp(tempDate.getTime());
            for( int i = date.length() - 1; i > 0; i-- ) {
                datechar = date.charAt(i);
                if( Character.isDigit(datechar) ) {
                    if( dateextrchar == null ) {
                    	dateextrchar = "";
                    }
                    dateextrchar = dateextrchar + datechar;
                } else {
                    if( dateextrchar == null ) {
                    	dateextrchar = "";
                    }
                    break;
                }
            }
            for( int j = pattern.length() - 1; j > 0; j-- ) {
                patternchar = pattern.charAt(j);
                if( Character.isLetter(patternchar) ) {
                    if( patternextrchar == null ) {
                    	patternextrchar = "";
                    }
                    patternextrchar = patternextrchar + patternchar;
                } else {
                    break;
                }
            }
            /*if( patternextrchar.length() != dateextrchar.length() ) {
               // throw new HelperException(helper.getMessage("ANAG-1320"));
            }*/
        } catch(final ParseException pe) {
            throw new HelperException(helper.getMessage("ANAG-1320"));
        }
        return retTimestamp;
    }

    /** This method creates the java.sql.Date object with the date value and pattern
     * passed to this function
     @ param String date
     @ param String pattern
     @ return java.sql.Date
     @ exception HelperException
     */

    public  java.sql.Date getDateFromDateString( final String date, final String pattern ) throws HelperException {
    	return new java.sql.Date(getTimestampFromDateString(date,pattern).getTime());
    }
    
    public Timestamp getTimestampAddingSixMonthsOneDay( final Timestamp input ) throws HelperException {
        Timestamp output = null;
        try {
        	final SimpleDateFormat simpleDateFormat = new SimpleDateFormat("dd/MM/yyyy");
        	final String inputDateString = simpleDateFormat.format(input);
        	final StringTokenizer tokenizer = new StringTokenizer(inputDateString, "/");
        	final int date = Integer.parseInt(tokenizer.nextToken());
        	final int month = Integer.parseInt(tokenizer.nextToken());
        	final int year = Integer.parseInt(tokenizer.nextToken());
        	final String parseString = "" + (date + 1) + "/" + (month + 6) + "/" + year;
            output = new Timestamp(simpleDateFormat.parse(parseString).getTime());
        } catch(final NumberFormatException e) {
            log4Debug.severeStackTrace(e);
            throw new HelperException(e.getMessage());
        } catch(final ParseException e) {
            log4Debug.severeStackTrace(e);
            throw new HelperException(e.getMessage());
        }
        return output;
    }

    public Date getDateSpecifiedYear( final Timestamp input, final int noOfYear ) {
    	Date date = null;
    	if ( input != null ) {
    		final Calendar calendar = Calendar.getInstance();
    		calendar.setTime(input);
    		calendar.add(Calendar.YEAR, noOfYear);
    		date = calendar.getTime();
    	}
    	return date;
    }
    
    public Timestamp getTimeStampSpecifiedYear( final Timestamp input , final int year ) {
    	Timestamp time = null;
  	   if ( input != null ) {
  		 final Calendar calendar = Calendar.getInstance();
 		 calendar.setTime(input);
 		 calendar.add(calendar.YEAR, year );
 		 time = new Timestamp(calendar.getTime().getTime());   
  	   }
	   return time;	
   }
    
    public Timestamp getTimeStampSpecifiedDay( final Timestamp input , final int day ) {
    	Timestamp time = null;
   	   if ( input != null ) {
   		 final Calendar calendar = Calendar.getInstance();
  		 calendar.setTime(input);
  		 calendar.add(calendar.DATE, day );
  		 time = new Timestamp(calendar.getTime().getTime());   
   	   }
 	   return time;	
    }
    public Timestamp getTimeStampSpecifiedMonth( final Timestamp input , final int month ) {
    	Timestamp time = null;
    	if ( input != null ) {
    	 final Calendar calendar = Calendar.getInstance();
   		 calendar.setTime(input);
   		 calendar.add(calendar.MONTH, month );
   		 time = new Timestamp(calendar.getTime().getTime());   
    	   }
  	   return time;	
     }
   
   public Date getDateSpecifiedMonth( final Timestamp input, final int noOfMonth ) {
	   Date date = null;
    	if ( input != null ) {
    		final Calendar calendar = Calendar.getInstance();
    		calendar.setTime(input);
    		calendar.add(Calendar.MONTH, noOfMonth);
    		date = calendar.getTime();
    	}
    	return date;
    }
    
    public Date getDateSpecifiedDay( final Date input, final int noOfDay ) {
    	 Date date = null;
    	if ( input != null ) {
    		final Calendar calendar = Calendar.getInstance();
    		calendar.setTime(input);
    		calendar.add(Calendar.DATE, noOfDay);
    		date = calendar.getTime();
    	}
    	return date;
    }

    public String getDateSpecifiedFormat( final Date input, final String pattern ) {
    	String result = null;
    	if ( input != null ) {
    		final SimpleDateFormat simpleDateFormat = new SimpleDateFormat(pattern);
    		result = simpleDateFormat.format(input);
    	}
    	return result;
    }

    public Timestamp getCurrentDateInTimeStampFormat() {
    	return new Timestamp(System.currentTimeMillis());
    }
    
    public static boolean isWorkingDay() {
		return DefaultCalendarFactory.getInstance(Locale.ITALY).isWorkingDay();
	}
    
    public Timestamp getCurrentDateForDocumentValidation(final boolean isThruXML) {
    	try {
			Timestamp currentDate = getTimestampFromDateString(formatDate(getCurrentDateInTimeStampFormat(),"ddMMyyyy"), "ddMMyyyy");
			if(isThruXML){
				currentDate = getTimeStampSpecifiedDay(currentDate,-10);
			}
			return currentDate;
		} catch (final HelperException e) {
			log4Debug.debugStackTrace(e);
		}
		return null;
    }
    
    public Timestamp getTruncCurrentDateInTimeStampFormat() {
    	Timestamp time = null;
    	try {
			time = getTimestampFromDateString(formatDate(getCurrentDateInTimeStampFormat(),"ddMMyyyy"), "ddMMyyyy");
		} catch (final HelperException e) {
			log4Debug.debugStackTrace(e);
		}
		return time;
    }
    
    public Boolean isValidDate(final String date,final String format) throws HelperException {
    	Boolean isValidDate = Boolean.FALSE;
		if(date != null)
		{
			try {
				final SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
				dateFormat.setLenient(false);
				dateFormat.parse(date);
				isValidDate = Boolean.TRUE;
			} catch (final ParseException ex) {
				log4Debug.warn("Date is Invalid : " , ex.getMessage());
				throw new HelperException(new AnagrafeHelper().getMessage("ANAG-1320"));
			}
		}
		return isValidDate;
	}
}
