from org.renjin.script import RenjinScriptEngineFactory

factory = RenjinScriptEngineFactory()
engine = factory.getScriptEngine()
engine.eval("df <- data.frame(x=1:10, y=(1:10)+rnorm(n=10))")
engine.eval("print(df)")
engine.eval("print(lm(y ~ x, df))")