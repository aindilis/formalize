relatedSystems([nlToFOL,nlToGDL,nlToPDDL,formalize,formalize2,nlu,freeLogicForm]).

hasSource('https://www.mat.unical.it/aspcomp2011/SystemCompetition').

%% formalismFamily

%% have reached a significant level of language standardization
%% has(formalismFamily,significantAmountOf(standardizationFn(language))).

neighborsOf(answerSetProgramming,[answerSetProgramming,constraintHandlingRules,satisfiabilityModuloTheories,planningDomainDefinitionLanguage]).

hasAcronym(answerSetProgramming,'ASP').
hasAcronym(constraintHandlingRules,'CHR').
hasAcronym(satisfiabilityModuloTheories,'SMT-LIB').
hasAcronym(planningDomainDefinitionLanguage,'PDDL').
%% hasAcronym(X,'TPTP').

are([answerSetProgramming,constraintHandlingRules,satisfiabilityModuloTheories,planningDomainDefinitionLanguage],formalismFamily).

usedIn('TPTP',automatedTheoremProvingSystemCompetition).
hasAcronym(automatedTheoremProvingSystemCompetition,'CASC').

