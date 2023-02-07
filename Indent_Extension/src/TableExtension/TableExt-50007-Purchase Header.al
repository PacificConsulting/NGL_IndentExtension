tableextension 50007 Purchase_Header_ext extends "Purchase Header"
{
    // version NAVW19.00.00.48466,NAVIN9.00.00.48466,GITLEXIM,PCPL/NGL/001,TFS180484,PCPL/QC/V3/001

    fields
    {



        field(50014; "PO Created"; Boolean)
        {
            Description = 'pcpl002410oct2018';
        }
        // field(50016; "Closed PO"; Boolean)
        // {
        //     Description = '//PCPL 38';
        // }
    }
    procedure UpdateIndent()
    var
        IndentPO: Record 50005;
        POLine: Record 39;
    begin
        IndentPO.RESET;
        IndentPO.SETRANGE(IndentPO."P.O.No.", "No.");
        IF IndentPO.FIND('-') THEN
            IndentPO.DELETEALL;
        POLine.SETRANGE(POLine."Document No.", "No.");
        IF POLine.FINDFIRST THEN BEGIN
            REPEAT
                IF POLine."Indent No." <> '' THEN BEGIN
                    IndentPO.INIT;
                    IndentPO.VALIDATE(IndentPO."Document No.", POLine."Indent No.");
                    IndentPO.VALIDATE(IndentPO."Line No.", POLine."Indent Line No.");
                    IndentPO.VALIDATE(IndentPO.Type, POLine.Type);
                    IndentPO.VALIDATE(IndentPO."No.", POLine."No.");
                    IndentPO.VALIDATE(IndentPO."PO Line No.", POLine."Line No.");
                    IndentPO.VALIDATE(IndentPO."Location Code", POLine."Location Code");
                    IndentPO.VALIDATE(IndentPO."P.O.Qty", POLine.Quantity);
                    IF "Document Type" = "Document Type"::Order THEN
                        IndentPO.VALIDATE(IndentPO."P.O.No.", POLine."Document No.");
                    IndentPO.VALIDATE(IndentPO."P.O.Date", POLine."Posting Date");
                    IndentPO.INSERT(TRUE);
                    IndentPO.VALIDATE(IndentPO."P.O.Qty");  //ROBOSOFT-V001
                END;
            UNTIL POLine.NEXT = 0;
        END;
    end;

    procedure UpdateReq()
    var
        PurchLine: Record 39;
        IndentPO: Record 50005;
        ReqLine: Record 246;
    begin
        IndentPO.RESET;
        IndentPO.SETRANGE(IndentPO."P.O.No.", "No.");
        IF IndentPO.FINDSET THEN BEGIN
            REPEAT
                PurchLine.SETRANGE(PurchLine."Document No.", "No.");
                IF PurchLine.FINDFIRST THEN BEGIN
                    PurchLine.SETRANGE(PurchLine."Indent No.", IndentPO."Document No.");
                    PurchLine.SETRANGE(PurchLine.Type, IndentPO.Type);
                    PurchLine.SETRANGE(PurchLine."No.", IndentPO."No.");
                    PurchLine.SETRANGE(PurchLine."Line No.", IndentPO."PO Line No.");
                    IF PurchLine.FINDFIRST THEN
                        IF PurchLine."Indent No." <> '' THEN BEGIN
                            ReqLine.RESET;
                            ReqLine.SETRANGE(ReqLine."Entry no", IndentPO."Document No.");
                            //        ReqLine.SETRANGE(ReqLine."Indent Line No",IndentPO."PO Line No.");
                            ReqLine.SETRANGE(ReqLine.Type, IndentPO.Type);
                            ReqLine.SETRANGE(ReqLine."No.", IndentPO."No.");
                            ReqLine.SETRANGE(ReqLine."Location Code", IndentPO."Location Code");
                            IF ReqLine.FINDSET THEN BEGIN
                                REPEAT
                                    IF ReqLine.Quantity > 0 THEN BEGIN
                                        // REPEAT
                                        IF IndentPO."P.O.Qty" > ReqLine.Quantity THEN BEGIN
                                            IndentPO."P.O.Qty" -= ReqLine.Quantity;
                                            ReqLine.Quantity := 0;
                                        END ELSE BEGIN
                                            ReqLine.Quantity -= IndentPO."P.O.Qty";
                                            IndentPO."P.O.Qty" := 0;
                                        END;

                                        //UNTIL ReqLine.NEXT=0;
                                    END;
                                    //ELSE
                                    // ReqLine.NEXT;
                                    //         MESSAGE('%1,%2',ReqLine.Quantity,IndentPO."P.O.Qty");
                                    ReqLine.MODIFY;
                                    //Abhinav-31.03.12---Start
                                    IF ReqLine.Quantity = 0 THEN BEGIN
                                        ReqLine.DELETE;
                                        //      IndentPO.DELETE;
                                    END;
                                //Abhinav-31.03.12---Start
                                UNTIL ReqLine.NEXT = 0;
                            END;
                        END;

                END;
            UNTIL IndentPO.NEXT = 0;
        END;

    end;

}

