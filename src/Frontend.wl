BeginPackage["Notebook`Editor`JSProcessor`", {
    "JerryI`Notebook`", 
    "JerryI`Notebook`Evaluator`", 
    "JerryI`Notebook`Kernel`", 
    "JerryI`Notebook`Transactions`",
    "JerryI`Misc`Events`"
}]

Begin["`Internal`"]

JSQ[t_Transaction] := (StringMatchQ[t["Data"], ".js\n"~~___] )

evaluator  = StandardEvaluator["Name" -> "JS Evaluator", "InitKernel" -> init, "Pattern" -> (_?JSQ), "Priority"->(3)];

    StandardEvaluator`ReadyQ[evaluator, k_] := (
        If[! TrueQ[k["ReadyQ"] ] || ! TrueQ[k["ContainerReadyQ"] ],
            EventFire[t, "Error", "Kernel is not ready"];
            StandardEvaluator`Print[evaluator, "Kernel is not ready"];
            False
        ,
            Kernel`Init[k, 
                    Print["Init JS JS JS Kernel (Local)"];
                    Notebook`Kernel`JSEvaluator = Function[t, 

                        EventFire[Internal`Kernel`Stdout[ t["Hash"] ], "Result", <|"Data" -> t["Data"], "Meta" -> Sequence["Display"->"js"] |> ];
                        EventFire[Internal`Kernel`Stdout[ t["Hash"] ], "Finished", True];
                    ];
            , "Once"->True];

    

            True
        ]
    );

StandardEvaluator`Evaluate[evaluator, k_, t_] := Module[{list},
    t["Evaluator"] = Notebook`Kernel`JSEvaluator;
    t["Data"] = StringDrop[t["Data"], 4];

    StandardEvaluator`Print[evaluator, "Kernel`Submit!"];
    Kernel`Submit[k, t];    
];  

init[k_] := Module[{},
    Print["Kernel init..."];
    
]


End[]

EndPackage[]