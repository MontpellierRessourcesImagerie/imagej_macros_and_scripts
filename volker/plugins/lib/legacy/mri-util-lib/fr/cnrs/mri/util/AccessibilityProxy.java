/*
This file is part of the Montpellier RIO Imaging mri-util-lib package.
 
(c) 2011 INSERM
This software is developed at Montpellier RIO Imaging (IFR 122), Montpellier, France (www.mri.cnrs.fr)
Developer: Volker Baecker (volker.baecker@mri.cnrs.fr) 

The Montpellier RIO Imaging mri-util-lib package contains different simple tools that
are needed in multiple projects.

This software is governed by the CeCILL-B license under French law and
abiding by the rules of distribution of free software.  You can  use, 
modify and/ or redistribute the software under the terms of the CeCILL-B
license as circulated by CEA, CNRS and INRIA at the following URL
"http://www.cecill.info". 

As a counterpart to the access to the source code and  rights to copy,
modify and redistribute granted by the license, users are provided only
with a limited warranty  and the software's author,  the holder of the
economic rights,  and the successive licensors  have only  limited
liability. 

In this respect, the user's attention is drawn to the risks associated
with loading,  using,  modifying and/or developing or reproducing the
software by the user in light of its specific status of free software,
that may mean  that it is complicated to manipulate,  and  that  also
therefore means  that it is reserved for developers  and  experienced
professionals having in-depth computer knowledge. Users are therefore
encouraged to load and test the software's suitability as regards their
requirements in conditions enabling the security of their systems and/or 
data to be ensured and,  more generally, to use and operate it in the 
same conditions as regards security. 

The fact that you are presently reading this means that you have had
knowledge of the CeCILL-B license and that you accept its terms. 
*/
package fr.cnrs.mri.util;

import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.logging.Logger;

import fr.cnrs.mri.util.logging.LoggingUtil;

/**
 * Allows to call protected and private methods for testing purposes.
 * 
 * @author Volker Baecker
 */
public class AccessibilityProxy {
	@SuppressWarnings("unchecked")
	protected Class[] parameterTypes;
	protected Method method;
	protected Object[] parameter;
	protected Object receiver;
	protected Object resultType;
	protected Object result;
	private Logger logger;
	
	public AccessibilityProxy() {
		this.logger = LoggingUtil.getLoggerFor(this);
	}
	
	public Object executeSuperclassMethod(Object resultType, Object receiver, String methodName, Object[] params) {
		this.resultType = resultType;
		this.receiver = receiver;  
		parameter = params;
		setupParameterTypes(params);
		result = null;
		try {
			method = receiver.getClass().getSuperclass().getDeclaredMethod(methodName, parameterTypes);
			method.setAccessible(true);
			if (resultType!=null) {
				result = method.invoke(receiver, parameter);
			} else {
				method.invoke(receiver, parameter);
			}
		} catch (SecurityException e) {
			logger.warning(LoggingUtil.getMessageAndStackTrace(e));
		} catch (NoSuchMethodException e) {
			try {
				method = receiver.getClass().getSuperclass().getSuperclass().getDeclaredMethod(methodName, parameterTypes);
				method.setAccessible(true);
				if (resultType!=null) {
					result = method.invoke(receiver, parameter);
				} else {
					method.invoke(receiver, parameter);
				}
			} catch (SecurityException exc) {
				logger.warning(LoggingUtil.getMessageAndStackTrace(exc));
			} catch (NoSuchMethodException exc) {
				logger.warning(LoggingUtil.getMessageAndStackTrace(exc));
			} catch (IllegalArgumentException exc) {
				logger.warning(LoggingUtil.getMessageAndStackTrace(exc));
			} catch (IllegalAccessException exc) {
				logger.warning(LoggingUtil.getMessageAndStackTrace(exc));
			} catch (InvocationTargetException exc) {
				logger.warning(LoggingUtil.getMessageAndStackTrace(exc));
			}
		} catch (IllegalArgumentException e1) {
			logger.warning(LoggingUtil.getMessageAndStackTrace(e1));
		} catch (IllegalAccessException e1) {
			logger.warning(LoggingUtil.getMessageAndStackTrace(e1));
		} catch (InvocationTargetException e1) {
			logger.warning(LoggingUtil.getMessageAndStackTrace(e1));
		}
		return result;
	}
	
	@SuppressWarnings("unchecked")
	public Object newObject (Class aClass) {
		Object result = null;
		try {
			Constructor aConstructor = aClass.getDeclaredConstructors()[0];
			aConstructor.setAccessible(true);
			Object[] params = {};
			result = aConstructor.newInstance( params);
		} catch (IllegalArgumentException e) {
			logger.warning(LoggingUtil.getMessageAndStackTrace(e));
		} catch (InstantiationException e) {
			logger.warning(LoggingUtil.getMessageAndStackTrace(e));
		} catch (IllegalAccessException e) {
			logger.warning(LoggingUtil.getMessageAndStackTrace(e));
		} catch (InvocationTargetException e) {
			logger.warning(LoggingUtil.getMessageAndStackTrace(e));
			logger.warning(LoggingUtil.getMessageAndStackTrace(e.getCause()));
		}
		return result;
	}
	/**
	 * @param params
	 */
	protected void setupParameterTypes(Object[] params) {
		parameterTypes = getParameterClasses(params);
	}

	
	public void setSuperclassField(Object receiver, String name, Object value) {
		try {
			Field theField = receiver.getClass().getSuperclass().getDeclaredField(name);
			theField.setAccessible(true);
			theField.set(receiver, value);
		} catch (SecurityException e) {
			logger.warning(LoggingUtil.getMessageAndStackTrace(e));
		} catch (NoSuchFieldException e) {
			logger.warning(LoggingUtil.getMessageAndStackTrace(e));
		} catch (IllegalArgumentException e) {
			logger.warning(LoggingUtil.getMessageAndStackTrace(e));
		} catch (IllegalAccessException e) {
			logger.warning(LoggingUtil.getMessageAndStackTrace(e));
		}
	}
	
	public Object getSuperclassField(Object receiver, String name) {
		try {
			Field theField = receiver.getClass().getSuperclass().getDeclaredField(name);
			theField.setAccessible(true);
			Object result = theField.get(receiver);
			return result;
		} catch (SecurityException e) {
			logger.warning(LoggingUtil.getMessageAndStackTrace(e));
		} catch (NoSuchFieldException e) {
			logger.warning(LoggingUtil.getMessageAndStackTrace(e));
		} catch (IllegalArgumentException e) {
			logger.warning(LoggingUtil.getMessageAndStackTrace(e));
		} catch (IllegalAccessException e) {
			logger.warning(LoggingUtil.getMessageAndStackTrace(e));
		}
		return null;
	}
	
	@SuppressWarnings("unchecked")
	static public Object getField(Object receiver, String name) {
		Class aClass = receiver.getClass();
		boolean found = false;
		while (aClass != Object.class) {
			try {
				found = true;
				Field theField = aClass.getDeclaredField(name);
				if (!found) continue;
				theField.setAccessible(true);
				Object result = theField.get(receiver);
				if (found) return result;
			} catch (SecurityException e) {
				LoggingUtil.getLoggerFor(AccessibilityProxy.class).warning(LoggingUtil.getMessageAndStackTrace(e));
			} catch (NoSuchFieldException e) {
				found = false;
				aClass = aClass.getSuperclass();
			} catch (IllegalArgumentException e) {
				LoggingUtil.getLoggerFor(AccessibilityProxy.class).warning(LoggingUtil.getMessageAndStackTrace(e));
			} catch (IllegalAccessException e) {
				LoggingUtil.getLoggerFor(AccessibilityProxy.class).warning(LoggingUtil.getMessageAndStackTrace(e));
			}
			
		}
		return null;
	}
	
	@SuppressWarnings("unchecked")
	static public void setField(Object receiver, String name, Object value) {
		Class aClass = receiver.getClass();
		boolean found = false;
		while (aClass != Object.class) {
			try {
				found = true;
				Field theField = aClass.getDeclaredField(name);
				if (!found) continue;
				theField.setAccessible(true);
				theField.set(receiver, value);
				if (found) break;
			} catch (SecurityException e) {
				LoggingUtil.getLoggerFor(AccessibilityProxy.class).warning(LoggingUtil.getMessageAndStackTrace(e));
			} catch (NoSuchFieldException e) {
				found = false;
				aClass = aClass.getSuperclass();
			} catch (IllegalArgumentException e) {
				LoggingUtil.getLoggerFor(AccessibilityProxy.class).warning(LoggingUtil.getMessageAndStackTrace(e));
			} catch (IllegalAccessException e) {
				LoggingUtil.getLoggerFor(AccessibilityProxy.class).warning(LoggingUtil.getMessageAndStackTrace(e));
			}
		}
	}
	
	@SuppressWarnings("unchecked")
	static protected Class[] getParameterClasses(Object[] params) {
		Class[] types = new Class[params.length];
		for (int i=0; i<params.length; i++) {
			types[i] = params[i].getClass();
			if (params[i].getClass()==Integer.class) {
				types[i] = int.class;
			}
			if (params[i].getClass()==Boolean.class) {
				types[i] = boolean.class;
			}
			if (params[i].getClass()==Double.class) {
				types[i] = double.class;
			}
		}
		return types;
	}
	
	@SuppressWarnings("unchecked")
	static public Object execute(Object resultType, Object receiver, String methodName, Object[] params) {
		Class aClass = receiver.getClass();
		boolean found = false;
		Class[] parameterTypes = getParameterClasses(params);
		Object result = null;
		Method method = null;
		while (aClass != Object.class) {
			try {
				found = true;
				method = aClass.getDeclaredMethod(methodName, parameterTypes);
				if (!found) continue;
				method.setAccessible(true);
				if (resultType!=null) {
					result = method.invoke(receiver, params);
				} else {
					method.invoke(receiver, params);
				}
				if (found) break;
			} catch (SecurityException e) {
				LoggingUtil.getLoggerFor(AccessibilityProxy.class).warning(LoggingUtil.getMessageAndStackTrace(e));
			} catch (NoSuchMethodException e) {
				aClass = aClass.getSuperclass();
			} catch (IllegalArgumentException e) {
				LoggingUtil.getLoggerFor(AccessibilityProxy.class).warning(LoggingUtil.getMessageAndStackTrace(e));
			} catch (IllegalAccessException e) {
				LoggingUtil.getLoggerFor(AccessibilityProxy.class).warning(LoggingUtil.getMessageAndStackTrace(e));
			} catch (InvocationTargetException e) {
				LoggingUtil.getLoggerFor(AccessibilityProxy.class).warning(LoggingUtil.getMessageAndStackTrace(e));
			}
		}
		return result;
	}

	/**
	 * Call a public, private or protected instance method via reflection.
	 *  
	 * @param receiver		the object that receives the message
	 * @param methodName	the name of the method to be called
	 * @param parameter		an array of parameter objects
	 * @return	the object the called method returns
	 */
	public Object call(Object receiver, String methodName, Object[] parameter) {
		Class<?>[] parameterClasses = new Class<?>[parameter.length];
		int index = 0;
		for (Object param : parameter) {
			parameterClasses[index] = param.getClass();
			index++;
		}
		Class<?> aClass = receiver.getClass();
		Object result = null;
		while (aClass!=Object.class) {
			try {
				Method method = aClass.getDeclaredMethod(methodName, parameterClasses);
				method.setAccessible(true);
				result = method.invoke(receiver, parameter);
				return result;
			} catch (SecurityException e) {
				LoggingUtil.getLoggerFor(this).finest(LoggingUtil.getMessageAndStackTrace(e));
			} catch (NoSuchMethodException e) {
				LoggingUtil.getLoggerFor(this).finest(LoggingUtil.getMessageAndStackTrace(e));
			} catch (IllegalArgumentException e) {
				LoggingUtil.getLoggerFor(this).finest(LoggingUtil.getMessageAndStackTrace(e));
			} catch (IllegalAccessException e) {
				LoggingUtil.getLoggerFor(this).finest(LoggingUtil.getMessageAndStackTrace(e));
			} catch (InvocationTargetException e) {
				LoggingUtil.getLoggerFor(this).finest(LoggingUtil.getMessageAndStackTrace(e));
			} finally {
				aClass =aClass.getSuperclass();
			}
		}
		return result;
	}
	
	@SuppressWarnings("unchecked")
	public	static Object createObject(String className) {
	      Object object = null;
	      try {
	          Class classDefinition = Class.forName(className);
	          object = classDefinition.newInstance();
	      } catch (InstantiationException e) {
	    	  LoggingUtil.getLoggerFor(AccessibilityProxy.class).warning(LoggingUtil.getMessageAndStackTrace(e));
	      } catch (IllegalAccessException e) {
	    	  LoggingUtil.getLoggerFor(AccessibilityProxy.class).warning(LoggingUtil.getMessageAndStackTrace(e));
	      } catch (ClassNotFoundException e) {
	    	  LoggingUtil.getLoggerFor(AccessibilityProxy.class).warning(LoggingUtil.getMessageAndStackTrace(e));
	      }
	      return object;
	   }
}
