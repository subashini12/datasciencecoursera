package it.sella.anagrafe.predicate;

/**
 * @author GBS03447
 *
 * @param <T>
 */
public interface Predicate<T> {
	
	boolean apply(T type);
}
