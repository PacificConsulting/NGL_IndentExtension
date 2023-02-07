pageextension 50123 Req_Worksheet extends "Req. Worksheet"
{
    // version NAVW19.00.00.45778

    layout
    {


    }
    actions
    {

        //Unsupported feature: PropertyDeletion on "Action 61". Please convert manually.

        //Unsupported feature: PropertyDeletion on "Action 83". Please convert manually.

        //Unsupported feature: PropertyDeletion on "Action 53". Please convert manually.

        addafter("Inventory Purchase Orders")
        {
            action("Create Indent")
            {
                Image = worksheet;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = all;

                trigger OnAction();
                begin
                    CreateIndent;
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        SetRange(Indented, false);
    end;

    trigger OnAfterGetRecord()
    BEGIN
        SetRange(Indented, false);
    END;

    var
        RequisionLine: Record 246;
        IndentHeader: Record 50002;
        IndentLine: Record 50003;
        JnlSelected: Boolean;
        IndentMergeLine: Record 50004;
        Qty: Decimal;
        Qty1: Decimal;
        ItemRec: Record 27;
        ReqWork: Record 246;
        NoSeries: Record 308;
        PurchSetup: Record 312;
        noseries1: Record 308;
        NoSeriesMgt: Codeunit 396;
        RequisitionRec: Record 246;

    procedure CreateIndent();
    begin
        SETRANGE(Indented, FALSE);
        SETRANGE("Worksheet Template Name", "Worksheet Template Name");
        SETRANGE("Journal Batch Name", "Journal Batch Name");
        IF FINDFIRST THEN BEGIN
            PurchSetup.GET;
            noseries1.RESET;
            noseries1.SETRANGE(Code, PurchSetup."Indent No.1");
            IF noseries1.FINDSET THEN
                REPEAT
                BEGIN
                    IF IndentHeader."No." = '' THEN BEGIN
                        TestNoSeries;
                        NoSeriesMgt.InitSeries(noseries1.Code, '', TODAY, IndentHeader."No.",
                        IndentHeader."No. Series");
                        IndentHeader.INSERT;
                    END;
                END;
                UNTIL noseries1.NEXT = 0;
        END;


        SETRANGE(Indented, FALSE);
        SETRANGE("Worksheet Template Name", "Worksheet Template Name");
        SETRANGE("Journal Batch Name", "Journal Batch Name");
        IF FINDSET THEN BEGIN
            REPEAT
                "Entry no" := IndentHeader."No.";
                MODIFY;

                IndentMergeLine."Document No." := IndentHeader."No.";
                IndentMergeLine.INSERT;

                SETRANGE("Worksheet Template Name", "Worksheet Template Name");
                SETRANGE("Journal Batch Name", "Journal Batch Name");
                SETFILTER(Indented, '%1', FALSE);
                IF FINDFIRST THEN BEGIN
                    REPEAT
                        "Entry no" := IndentHeader."No.";
                        MODIFY;
                        //Find Record in Indent Line Req

                        IndentMergeLine.RESET;
                        IndentMergeLine.SETRANGE(IndentMergeLine."Document No.", "Entry no");
                        IndentMergeLine.SETRANGE(IndentMergeLine."Entry Type", IndentMergeLine."Entry Type"::Indent);
                        IF IndentMergeLine.FINDLAST THEN BEGIN
                            IF IndentMergeLine."Line No." <> 0 THEN
                                IndentMergeLine."Line No." := IndentMergeLine."Line No." + 10000
                            ELSE
                                IndentMergeLine."Line No." := 10000;

                            IF IndentMergeLine.Type = 0 THEN
                                IndentMergeLine.Type := IndentMergeLine.Type::Item;
                            IndentMergeLine.INSERT;
                        END;


                        IndentMergeLine.INIT;
                        IndentMergeLine.Date := "Due Date";
                        IndentMergeLine."No." := "No.";
                        IndentMergeLine."Location Code" := "Location Code";
                        IndentMergeLine.Quantity := (Quantity);
                        IndentMergeLine."Unit of Measure Code" := "Unit of Measure Code";
                        IndentMergeLine."Requisition Line No." := "Line No.";
                        IndentMergeLine.Approved := "Accept Action Message";
                        IndentMergeLine.Description := Description;
                        IndentMergeLine."Description 2" := "Description 2";

                        //IndentLine."PO Qty":=CALCFIELD()
                        IndentMergeLine."Requisition Templet Name" := "Worksheet Template Name";
                        IndentMergeLine."Requisition Batch Name" := "Journal Batch Name";
                        IndentMergeLine.MODIFY;

                    UNTIL NEXT = 0;
                END;
            UNTIL NEXT = 0;
        END;

        //A002---End;
        //A001---Start
        //Abhinav New Code------------------------------------------Start
        SETRANGE(Indented, FALSE);
        SETRANGE("Worksheet Template Name", "Worksheet Template Name");
        SETRANGE("Journal Batch Name", "Journal Batch Name");
        IF FINDSET THEN BEGIN
            "Entry no" := IndentHeader."No.";
            MODIFY;
            IndentHeader.INIT;
            IndentHeader.Date := WORKDATE;
            IndentHeader."Shortcut Dimension 1 Code" := '';
            IndentHeader."Shortcut Dimension 2 Code" := '';
            IndentHeader."Location Code" := "Location Code";
            IndentHeader."Created By" := USERID;
            IndentHeader."Creation Date" := WORKDATE;
            IndentHeader.MODIFY;

            SETRANGE("Worksheet Template Name", "Worksheet Template Name");
            SETRANGE("Journal Batch Name", "Journal Batch Name");
            SETFILTER(Indented, '%1', FALSE);
            IF FINDFIRST THEN
                REPEAT


                    /*
                        ReqWork.SETRANGE(ReqWork."Worksheet Template Name","Worksheet Template Name");
                        ReqWork.SETRANGE(ReqWork."Journal Batch Name","Journal Batch Name");
                        ReqWork.SETFILTER(ReqWork.Indented,'%1',FALSE);
                      //  ReqWork.SETRANGE(ReqWork."No.","No.");  //PCPl/BRB
                        IF ReqWork.FINDFIRST THEN
                        BEGIN
                        REPEAT
                            ReqWork."Entry no":=IndentHeader."No.";
                            Qty+=ReqWork.Quantity;
                            ReqWork.Indented:=TRUE;
                            ReqWork.MODIFY;
                            Indented:=TRUE;
                            MODIFY;
                        UNTIL ReqWork.NEXT=0;
                        END;
                        */

                    IndentLine.RESET;
                    IndentLine.SETRANGE(IndentLine."Document No.", "Entry no");
                    IndentLine.SETRANGE(IndentLine."Entry Type", IndentLine."Entry Type"::Indent);

                    IF IndentLine.FINDLAST THEN
                        // BEGIN
                        //IF IndentLine."Line No."<>0 THEN
                        IndentLine."Line No." := IndentLine."Line No." + 10000
                    ELSE
                        IndentLine."Line No." := 10000;
                    // IF IndentLine.Type=0 THEN
                    IndentLine.Type := IndentLine.Type::Item;
                    //IndentLine.INSERT;
                    //END;
                    //"Indent Line No":= IndentLine."Line No.";
                    //MODIFY;

                    IndentLine.INIT;
                    IndentLine."Document No." := IndentHeader."No.";
                    IndentLine.INSERT;
                    //Qty:=0;
                    Indented := TRUE;
                    MODIFY;
                    IndentLine.Date := WORKDATE;
                    IndentLine.Type := IndentLine.Type::Item;
                    IndentLine."No." := "No.";
                    IndentLine."Location Code" := "Location Code";
                    IndentLine.Quantity := Quantity;
                    IndentLine."Unit of Measure Code" := "Unit of Measure Code";
                    IndentLine."Requisition Line No." := "Line No.";
                    //IndentLine.Approved:="Accept Action Message";
                    IndentLine.Description := Description;
                    IndentLine."Description 2" := "Description 2";
                    IndentLine."Requisition Templet Name" := "Worksheet Template Name";
                    IndentLine."Requisition Batch Name" := "Journal Batch Name";
                    IndentLine."Variant Code" := "Variant Code";
                    IndentLine."Gen. Prod. Posting Group" := "Gen. Prod. Posting Group";
                    IndentLine.Comment := Comment;
                    IndentLine.MODIFY;




                UNTIL NEXT = 0;
            MESSAGE('Indent Header Created for %1', "Entry no");


        END;


        //Abhinav New Code------------------------------------------End

    end;

    local procedure TestNoSeries(): Boolean;
    begin
        CASE IndentHeader."Entry Type" OF
            IndentHeader."Entry Type"::Indent:
                PurchSetup.TESTFIELD("Indent No.");

        END;
    end;

    procedure CreateIndent2();
    var
        RequisionLine: Record 246;
        IndentHeader: Record 50002;
        IndentLine: Record 50003;
        JnlSelected: Boolean;
        IndentMergeLine: Record 50004;
        Qty: Decimal;
        Qty1: Decimal;
        ItemRec: Record 27;
        ReqWork: Record 246;
        NoSeries: Record 308;
        PurchSetup: Record 312;
        noseries1: Record 308;
        NoSeriesMgt: Codeunit 396;
        RequisitionRec: Record 246;
        recindentheader: Record 50002;
        recprodordcomp: Record 5407;
        frmprodcomp: Page 5407;
        Transferline: Record 5741;
        lineno: Integer;
        frmfinishedprodlines: Page 99000868;
        recfinishedprodlines: Record 5406;
        recreqline: Record 246;
        recitem: Record 27;
    begin
        //For New No Series
        IF IndentHeader."No." = '' THEN
            IndentHeader.INSERT(TRUE);
        SETRANGE(Indented, FALSE);
        SETRANGE("Worksheet Template Name", "Worksheet Template Name");
        SETRANGE("Journal Batch Name", "Journal Batch Name");
        IF FINDFIRST THEN BEGIN
            PurchSetup.GET;
            noseries1.RESET;
            noseries1.SETRANGE(Code, PurchSetup."Indent No.");
            IF noseries1.FINDSET THEN
                REPEAT
                BEGIN
                    IF IndentHeader."No." = '' THEN BEGIN
                        TestNoSeries;
                        NoSeriesMgt.InitSeries(noseries1.Code, '', TODAY, IndentHeader."No.",
                        IndentHeader."No. Series");
                        IndentHeader.INSERT;
                    END;
                END;
                UNTIL noseries1.NEXT = 0;
        END;


        SETRANGE(Indented, FALSE);
        SETRANGE("Worksheet Template Name", "Worksheet Template Name");
        SETRANGE("Journal Batch Name", "Journal Batch Name");
        IF FINDFIRST THEN BEGIN
            REPEAT
                "Entry no" := IndentHeader."No.";
                MODIFY;

                IndentMergeLine."Document No." := IndentHeader."No.";
                IndentMergeLine.INSERT;
                //Find Record in Req. WorkSheet for Indent Line
                SETRANGE("Worksheet Template Name", "Worksheet Template Name");
                SETRANGE("Journal Batch Name", "Journal Batch Name");
                SETFILTER(Indented, '%1', FALSE);
                IF FINDFIRST THEN BEGIN
                    REPEAT
                        "Entry no" := IndentHeader."No.";
                        MODIFY;
                        //Find Record in Indent Line Req
                        IndentMergeLine.RESET;
                        IndentMergeLine.SETRANGE(IndentMergeLine."Document No.", "Entry no");
                        IndentMergeLine.SETRANGE(IndentMergeLine."Entry Type", IndentMergeLine."Entry Type"::Indent);
                        IF IndentMergeLine.FINDLAST THEN BEGIN
                            IF IndentMergeLine."Line No." <> 0 THEN
                                IndentMergeLine."Line No." := IndentMergeLine."Line No." + 10000
                            ELSE
                                IndentMergeLine."Line No." := 10000;
                            IF IndentMergeLine.Type = 0 THEN
                                IndentMergeLine.Type := IndentMergeLine.Type::Item;
                            IndentMergeLine.INSERT;
                        END;


                        IndentMergeLine.INIT;
                        IndentMergeLine.Date := "Due Date";
                        IndentMergeLine."No." := "No.";
                        IndentMergeLine."Location Code" := "Location Code";
                        IndentMergeLine.Quantity := (Quantity);
                        IndentMergeLine."Unit of Measure Code" := "Unit of Measure Code";
                        IndentMergeLine."Requisition Line No." := "Line No.";
                        IndentMergeLine.Approved := "Accept Action Message";
                        IndentMergeLine.Description := Description;
                        IndentMergeLine."Description 2" := "Description 2";
                        IndentMergeLine."Requisition Templet Name" := "Worksheet Template Name";
                        IndentMergeLine."Requisition Batch Name" := "Journal Batch Name";
                        IndentMergeLine.MODIFY;
                    UNTIL NEXT = 0;
                END;
            UNTIL NEXT = 0;
        END;

        //A002---End;

        //Abhinav New Code------------------------------------------Start
        SETRANGE(Indented, FALSE);
        SETRANGE("Worksheet Template Name", "Worksheet Template Name");
        SETRANGE("Journal Batch Name", "Journal Batch Name");
        IF FINDSET THEN BEGIN
            "Entry no" := IndentHeader."No.";
            MODIFY;

            IndentLine."Document No." := IndentHeader."No.";
            IndentLine.INSERT;
            IndentHeader.INIT;
            IndentHeader.Date := WORKDATE;
            IndentHeader."Shortcut Dimension 1 Code" := '';
            IndentHeader."Shortcut Dimension 2 Code" := '';
            IndentHeader."Location Code" := "Location Code";
            IndentHeader."Created By" := USERID;
            IndentHeader."Creation Date" := WORKDATE;
            IndentHeader.MODIFY;
            REPEAT
                Qty := 0;
                ReqWork.SETRANGE(ReqWork."Worksheet Template Name", "Worksheet Template Name");
                ReqWork.SETRANGE(ReqWork."Journal Batch Name", "Journal Batch Name");
                ReqWork.SETFILTER(ReqWork.Indented, '%1', FALSE);
                ReqWork.SETRANGE(ReqWork."No.", "No.");
                IF ReqWork.FINDFIRST THEN BEGIN
                    REPEAT
                        recindentheader.RESET;
                        recindentheader.SETRANGE(recindentheader."No.", ReqWork."Entry no");
                        IF recindentheader.FINDFIRST THEN BEGIN
                            recindentheader.MODIFY;
                        END;

                        ReqWork."Entry no" := IndentHeader."No.";
                        Qty += ReqWork.Quantity;
                        ReqWork.Indented := TRUE;
                        ReqWork.MODIFY;
                        Indented := TRUE;
                        MODIFY;
                    UNTIL ReqWork.NEXT = 0;
                END;
                IndentLine.RESET;
                IndentLine.SETRANGE(IndentLine."Document No.", ReqWork."Entry no");
                IndentLine.SETRANGE(IndentLine."Entry Type", IndentLine."Entry Type"::Indent);
                IF IndentLine.FINDLAST THEN BEGIN
                    IF IndentLine."Line No." <> 0 THEN
                        IndentLine."Line No." := IndentLine."Line No." + 10000
                    ELSE
                        IndentLine."Line No." := 10000;
                    "Indent Line No" := IndentLine."Line No.";
                    MODIFY;
                    IndentLine.Type := ReqWork.Type;
                    IndentLine.INSERT;
                END;
                IndentLine.INIT;
                IndentLine.Date := WORKDATE;
                IndentLine."No." := ReqWork."No.";
                IndentLine."Location Code" := "Location Code";
                IndentLine.Quantity := Qty;
                IndentLine."Unit of Measure Code" := "Unit of Measure Code";
                IndentLine."Requisition Line No." := "Line No.";
                IndentLine.Approved := "Accept Action Message";
                IndentLine.Description := Description;
                IndentLine."Description 2" := "Description 2";
                IndentLine."Requisition Templet Name" := "Worksheet Template Name";
                IndentLine."Requisition Batch Name" := "Journal Batch Name";
                IndentLine.MODIFY;
            UNTIL NEXT = 0;

            MESSAGE('Indent Header Created for %1', ReqWork."Entry no");

            Rec.RESET;
            Rec.SETRANGE(Indented, FALSE);
        END;

        //Abhinav New Code------------------------------------------End
    end;

    //Unsupported feature: PropertyChange. Please convert manually.

}

