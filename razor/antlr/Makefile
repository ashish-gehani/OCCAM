ANTLR_4_5=java -Xmx500M -cp "../../antlers/antlr-4.5-complete.jar" org.antlr.v4.Tool

ANTLR_4_6=java -Xmx500M -cp "../../antlers/antlr-4.6-complete.jar" org.antlr.v4.Tool

ANTLR_4_7=java -Xmx500M -cp "../../antlers/antlr-4.7-complete.jar" org.antlr.v4.Tool


all:
	@echo 'To regenerate the antlr4 python code, do "make antlr4"'

antlr4: antlr4_5


antlr4_5:
	${ANTLR_4_5} -Dlanguage=Python2 Argv.g4 -visitor

antlr4_6:
	${ANTLR_4_6} -Dlanguage=Python2 Argv.g4 -visitor

antlr4_7:
	${ANTLR_4_7} -Dlanguage=Python2 Argv.g4 -visitor



clean:
	rm -f *.pyc A*.py *.tokens *~
