package it.sella.anagrafe.predicate;

import java.util.ArrayList;
import java.util.Collection;

/**
 * @author GBS03447
 *
 */
public class PredicateImplimentation {
	
	/**
	 * @param target
	 * @param predicate
	 * @return
	 */
	public static <T> Collection<T> filter(final Collection<T> target, final Predicate<T> predicate) {
        final Collection<T> result = new ArrayList<T>();
        for (final T element : target) {
            if (predicate.apply(element)) {
                result.add(element);
            }
        }
        return result;
    }
}
