table 50003 "Indent Line"
{
    // version RSPL/INDENT/V3/001,PCPL-FA-1.0,PCPL-25/INCDoc,PCPL-JOB0001

    // Author        Code      Documentation
    // Venkatesh     VK001     To print Description of variant code
    // Nandesh       NG001     To List Items according to category selected on Indent Header


    fields
    {
        field(1; "Entry Type"; Option)
        {
            OptionCaption = 'Indent,Posted Indent';
            OptionMembers = Indent,"Posted Indent";
        }
        field(2; "Document No."; Code[20])
        {
            TableRelation = "Indent Header"."No." WHERE("Entry Type" = FIELD("Entry Type"));
            //This property is currently not supported
            //TestTableRelation = true;
            ValidateTableRelation = true;
        }
        field(3; "Line No."; Integer)
        {
            Editable = false;
        }
        field(4; Date; Date)
        {
            TableRelation = "Indent Header".Date;

            trigger OnValidate();
            begin
                TestApprove();
            end;
        }
        field(5; Type; Option)
        {
            OptionCaption = '" ,G/L Account,Item,,Fixed Asset"';
            OptionMembers = " ","G/L Account",Item,,"Fixed Asset","Charge (Item)";
        }
        field(6; "No."; Code[20])
        {
            TableRelation = IF (Type = CONST(Item)) Item."No."
            ELSE
            IF (Type = CONST("G/L Account")) "G/L Account"."No."
            ELSE
            IF (Type = CONST("Fixed Asset")) "Fixed Asset"."No.";

            trigger OnValidate();
            begin

                TestApprove();
                IF indentheader.GET("Document No.") THEN
                    "Location Code" := indentheader."Location Code";

                CompanyInformation.GET;
                "Indent Closing Date" := CALCDATE(CompanyInformation."Indent Closing Period", indentheader.Date);//pcpl002430oct


                CASE Type OF
                    Type::"G/L Account":
                        BEGIN
                            GLAcc.GET("No.");
                            GLAcc.CheckGLAcc;
                            Description := GLAcc.Name;
                            "Unit of Measure Code" := '';
                            "Item Category Code" := GLAcc."Gen. Prod. Posting Group";
                            //   Category := indentheader.Category;
                            //     indentheader.TESTFIELD(indentheader."Material category");
                            //      indentheader.TESTFIELD(indentheader.Purpose);

                        END;



                    Type::Item:
                        BEGIN
                            TESTFIELD("No.");
                            Item.GET("No.");
                            Item.TESTFIELD(Blocked, FALSE);
                            IF Item."Blocked Type" = Item."Blocked Type"::Indent THEN
                                ERROR('Blocked Type must not be Indent for this Item');

                            Item.TESTFIELD("Inventory Posting Group");
                            Item.TESTFIELD("Gen. Prod. Posting Group");
                            Description := Item.Description;
                            "Description 2" := Item."Description 2";
                            "Unit of Measure Code" := Item."Base Unit of Measure";
                            "Item Category Code" := Item."Item Category Code";
                            //   Category := indentheader.Category;
                            //  indentheader.TESTFIELD(indentheader."Material category");
                            // indentheader.TESTFIELD(indentheader.Purpose);
                        END;

                    Type::"Fixed Asset":
                        BEGIN
                            FA.GET("No.");
                            FA.TESTFIELD(Inactive, FALSE);
                            FA.TESTFIELD(Blocked, FALSE);
                            IF FA."Blocked Type" = Item."Blocked Type"::Indent THEN
                                ERROR('Blocked Type must not be Indent for this Fixed Asset');

                            FA.TESTFIELD("Gen. Prod. Posting Group");
                            Description := FA.Description;
                            "Description 2" := FA."Description 2";
                            "Unit of Measure Code" := '';
                            "Item Category Code" := indentheader."Material category";
                            Category := indentheader.Category;
                            //         indentheader.TESTFIELD(indentheader."Material category");
                            //    indentheader.TESTFIELD(indentheader.Purpose);

                        END;

                END;
                Status := TRUE;   //PCPl/BRB/21Dec18
            end;
        }
        field(7; "Location Code"; Code[20])
        {
            TableRelation = Location.Code;

            trigger OnValidate();
            begin
                TestApprove();
            end;
        }
        field(8; Quantity; Decimal)
        {

            trigger OnValidate();
            begin
                TestApprove();
                VALIDATE("PO Qty");
            end;
        }
        field(10; "PO Qty"; Decimal)
        {

            FieldClass = FlowField;
            Editable = true;
            CalcFormula = Sum("Purchase Line".Quantity WHERE("Document Type" = FILTER(Order),
                                                              "Indent No." = FIELD("Document No."),
                                                              "Location Code" = FIELD("Location Code"),
                                                              "No." = FIELD("No."),
                                                              "Indent Line No." = FIELD("Line No.")));

        }
        field(11; Approved; Boolean)
        {

            trigger OnValidate();
            begin
                //pcpl0024
                IF APPtatustpcpl <> 1 THEN BEGIN
                    recuserset.RESET;
                    recuserset.SETRANGE(recuserset."User ID", USERID);
                    IF recuserset.FINDFIRST THEN BEGIN
                        IF recuserset."Indent Approver" = FALSE THEN
                            ERROR('You Are not Authorised to modify this record');
                    END;
                END;
                //pcpl0024
                IF Approved = TRUE THEN BEGIN
                    IF ("Location Code" = '') THEN
                        ERROR('%1', 'Location Code should not be blank');
                    IF (Quantity = 0) THEN
                        ERROR('%1', 'Quanity should not 0');
                END;

                IF Approved = TRUE THEN
                    TESTFIELD("Requirement Date");


                IF Approved = TRUE THEN
                    "Approved Date" := WORKDATE;
            end;
        }
        field(12; Description; Text[50])
        {
        }
        field(13; "Description 2"; Text[50])
        {
        }
        field(14; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = IF (Type = CONST(Item)) "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."))
            ELSE
            "Unit of Measure";

            trigger OnValidate();
            var
                UnitOfMeasureTranslation: Record 5402;
            begin
            end;
        }
        field(15; "Requisition Line No."; Integer)
        {
        }
        field(16; "Requisition Templet Name"; Code[30])
        {
        }
        field(17; "Requisition Batch Name"; Code[30])
        {
        }
        field(18; "Outstanding True"; Boolean)
        {
        }
        field(19; Close; Boolean)
        {

            trigger OnValidate();
            begin
                IF Close = TRUE THEN
                    "Close UserID" := USERID;
            end;
        }
        field(20; "Description 3"; Text[60])
        {
        }
        field(21; "Material Requisitioned"; Text[50])
        {
        }
        field(22; Remark; Text[250])
        {
        }
        field(23; "USER ID"; Text[30])
        {
            Editable = false;
        }
        field(24; "FA Component Category"; Code[20])
        {
            //TableRelation = test3.test; //PCPL/NSW/MIG 15July22
        }
        field(25; "Requirement Date"; Date)
        {
        }
        field(26; "Product Group Code"; Code[20])
        {
            TableRelation = "Product Group".Code;
        }
        field(27; "Item Category Code"; Code[10])
        {
        }
        field(28; Category; Option)
        {
            OptionCaption = '" ,Engineering,Raw Materials,Lab Equipment,Lab Chemicals,Packing Material,,Safety,Production,Information Technology (IT)"';
            OptionMembers = " ",Engineering,"Raw Materials","Lab Equipment","Lab Chemicals","Packing Material",,Safety,Production,"Information Technology (IT)";
        }
        field(29; "Variant Code"; Code[10])
        {
            TableRelation = IF (Type = CONST(Item)) "Item Variant".Code WHERE("Item No." = FIELD("No."));

            trigger OnValidate();
            begin

                //VK001-BEGIN
                IF "Variant Code" <> '' THEN
                    RecVar.SETRANGE(RecVar."Item No.", "No.");
                RecVar.SETRANGE(RecVar.Code, "Variant Code");
                IF RecVar.FINDFIRST THEN BEGIN
                    Description := RecVar.Description;
                    "Description 2" := RecVar."Description 2";//pcpl0024
                END
                ELSE BEGIN
                    IF Item.GET("No.") THEN
                        Description := Item.Description;
                    "Description 2" := Item."Description 2";//pcpl0024
                END;
                //VK001-END
            end;
        }
        field(30; "Approved Date"; Date)
        {
            Editable = true;
        }
        field(31; Status; Boolean)
        {

            trigger OnValidate();
            begin

                IF Status = TRUE THEN
                    "Releaser User ID" := USERID;
                "Release Date and Time" := CURRENTDATETIME;
                MODIFY;
            end;
        }
        field(32; "Approved By"; Code[50])
        {
            Editable = false;
        }
        field(33; "Cost Allocation Dimension"; Code[20])
        {
            TableRelation = "Dimension Value".Code WHERE("Dimension Code" = CONST('CA'));
        }
        field(34; "Release Date and Time"; DateTime)
        {
        }
        field(35; "Releaser User ID"; Code[50])
        {
        }
        field(36; "Approved Date and Time"; DateTime)
        {
        }
        field(37; "End Use"; Text[50])
        {

            trigger OnLookup();
            begin
                FSC.RESET;
                IF PAGE.RUNMODAL(0, FSC) = ACTION::LookupOK THEN
                    "End Use" := FSC.Name;
            end;
        }
        field(39; "Close UserID"; Code[50])
        {
        }
        field(40; "Comment for Close"; Text[100])
        {
        }
        field(41; Closingqty; Decimal)
        {
            CalcFormula = Sum("Warehouse Entry"."Qty. (Base)" WHERE("Location Code" = FIELD("Location Code"),
                                                                     "Item No." = FIELD("No.")));
            FieldClass = FlowField;
        }
        field(42; "Vendor Unit_ Price"; Decimal)
        {
            Description = '//PCPL/BRB/Portal';
        }
        field(43; "Vendor Discount %"; Decimal)
        {
            Description = '//PCPL/BRB/Portal';
        }
        field(44; "Lead Time"; Time)
        {
            Description = '//PCPL/BRB/Portal';
        }
        field(45; Availability; Text[60])
        {
        }
        field(46; "Self Life"; Text[60])
        {
        }
        field(47; Observation; Text[60])
        {
        }
        field(48; "Vendor No."; Code[20])
        {
            TableRelation = Vendor;

            trigger OnValidate();
            begin
                IF Vend.GET("Vendor No.") THEN
                    "Vendor Name" := Vend.Name;
            end;
        }
        field(49; "Vendor Name"; Text[60])
        {
        }
        field(50; Selected; Boolean)
        {

            trigger OnValidate();
            begin
                TESTFIELD("Quotation Qty");   //PCPL/BRB/30Nov18
            end;
        }
        field(51; "Mail Already Sent"; Boolean)
        {
        }
        field(52; "Create PO"; Boolean)
        {
        }
        field(53; "PO Created"; Option)
        {
            OptionCaption = 'Open,Created';
            OptionMembers = Open,Created;
        }
        field(54; "Quotation Qty"; Decimal)
        {
        }
        field(55; "Indent Closing Date"; Date)
        {
            Description = 'pcpl002430oct';
        }
        field(56; "Gen. Prod. Posting Group"; Code[10])
        {
            Description = 'PCPL BRB';
            TableRelation = "Gen. Product Posting Group";
        }
        field(57; Comment; Text[230])
        {
            Description = 'PCPL BRB';
        }
        field(58; "Job Maintenance No."; Code[20])
        {
            Description = '//PCPL-FA-1.0';
        }
        field(59; "FA Sub Category"; Code[20])
        {
            Description = 'PCPL0017';
            TableRelation = "Dimension Value".Code WHERE("Dimension Code" = FILTER('FA SUB CATEGORY'),
                                                          "Dimension Value Type" = CONST(Standard));
        }
        field(60; "Main Category"; Code[20])
        {
            Description = 'PCPL0017';
            TableRelation = "Dimension Value".Code WHERE("Dimension Code" = FILTER('MAIN CATEGORY'));
        }
        field(50011; "Job No."; Code[20])
        {
            AccessByPermission = TableData 167 = R;
            Description = 'PCPL-JOB0001';

            trigger OnLookup();
            var
                JobPlanningLine: Record 1003;
            begin
            end;

            trigger OnValidate();
            var
                JobPlanningLine: Record 1003;
            begin
            end;
        }
        field(50012; "Job Task No."; Code[10])
        {
            Description = 'PCPL-JOB0001';
        }
        field(50013; "Job Planning Line No."; Integer)
        {
            Description = 'PCPL-JOB0001';
        }
    }

    keys
    {
        key(Key1; "Entry Type", "Document No.", "Line No.")
        {
        }
        key(Key2; "Location Code", "No.")
        {
        }
        key(Key3; Type, "Document No.")
        {
            SumIndexFields = Quantity;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete();
    begin
        //TestApprove();
    end;

    trigger OnInsert();
    begin
        //PCPL41_05032020_S
        indentheader.RESET;
        indentheader.SETRANGE("No.", "Document No.");
        IF indentheader.FINDFIRST THEN BEGIN
            IF indentheader.Status = indentheader.Status::Released THEN
                ERROR('Please reopen the order.');
        END;
        //PCPL41_05032020_E

        indentline.SETRANGE(indentline."Entry Type", "Entry Type");
        indentline.SETRANGE(indentline."Document No.", "Document No.");
        IF indentline.FINDLAST THEN BEGIN
            "Line No." := indentline."Line No." + 10000;
        END ELSE BEGIN
            "Line No." := 10000
        END;

        //to get date
        indentheader.GET("Document No.");
        indentheader.TESTFIELD(indentheader.Date);
        Rec.Date := indentheader.Date;
        "Location Code" := indentheader."Location Code";
        "USER ID" := USERID;
    end;

    trigger OnModify();
    begin
        APPtatustpcpl := 1;//pcpl0024
        VALIDATE(Approved)
    end;

    var
        indentheader: Record 50002;
        indentline: Record 50003;
        Item: Record 27;
        GLAcc: Record 15;
        FA: Record 5600;
        Text000: Label 'Indnet No. %1:';
        Text001: Label 'The program cannot find this purchase line.';
        NextLineNo: Integer;
        indentline1: Record 50003;
        outstandqty: Decimal;
        Des: Decimal;
        PurchaseLinesForm: Page 518;
        RecVar: Record 5401;
        IH: Record 50002;
        ITM: Record 27;
        GL: Record 15;
        RFA: Record 5600;
        FSC: Record 5608;
        Vend: Record 23;
        CompanyInformation: Record 79;
        recuserset: Record 91;
        APPtatustpcpl: Integer;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20]);
    var
        DimMgt: Codeunit 408;
    begin
        /*DimMgt.ValidateDimValueCode(FieldNumber,ShortcutDimCode);
        IF "Line No." <> 0 THEN BEGIN
          DimMgt.SaveDocDim(
            DATABASE::Indent,0,"Document No.",
            "Line No.",FieldNumber,ShortcutDimCode);
          MODIFY;
        END ELSE
          DimMgt.SaveTempDim(FieldNumber,ShortcutDimCode);
        */

    end;

    local procedure TestApprove();
    begin
        IF Approved = TRUE THEN
            ERROR('%1%2', 'No Change in Line for line No', "Line No.");
    end;

    local procedure GetIndentHeader();
    begin
        TESTFIELD("Document No.");
    end;

    procedure InsertPurchLineFromIndentLine(var PurchLine: Record 39);
    var
        PurchInvHeader: Record 38;
        PurchOrderHeader: Record 38;
        PurchOrderLine: Record 39;
        TempPurchLine: Record 39;
        PurchSetup: Record 312;
        TransferOldExtLines: Codeunit 379;
        ItemTrackingMgt: Codeunit 6500;
        NextLineNo: Integer;
        ExtTextLine: Boolean;
        "**sh": Integer;
        IndentPO: Record 50005;
        IndentHeader: Record 50002;
    begin
        SETRANGE("Document No.", "Document No.");

        TempPurchLine := PurchLine;
        IF PurchLine.FIND('+') THEN
            NextLineNo := PurchLine."Line No." + 10000
        ELSE
            NextLineNo := 10000;

        IndentPO.RESET;
        IndentPO.SETFILTER(IndentPO."Document No.", "Document No.");
        IndentPO.SETRANGE(IndentPO."PO Line No.", "Line No.");
        IndentPO.SETRANGE(IndentPO.Type, Type);
        IndentPO.SETFILTER(IndentPO."No.", "No.");
        IndentPO.SETFILTER(IndentPO."Location Code", "Location Code");
        IF IndentPO.FINDFIRST THEN
            REPEAT
                "PO Qty" += IndentPO."P.O.Qty";
            UNTIL IndentPO.NEXT = 0;


        IF PurchInvHeader."No." <> TempPurchLine."Document No." THEN
            PurchInvHeader.GET(TempPurchLine."Document Type", TempPurchLine."Document No.");

        PurchLine.INIT;
        REPEAT
            PurchLine."Line No." := NextLineNo;
            PurchLine."Document Type" := TempPurchLine."Document Type";
            PurchLine."Document No." := TempPurchLine."Document No.";
            PurchLine.Type := Type;
            PurchLine.VALIDATE(PurchLine."No.", "No.");
            PurchLine.Description := Description;
            PurchLine."Description 2" := "Description 2";
            //PurchLine."Description 3"        :=   "Description 3";
            //      PurchLine.VALIDATE(PurchLine."Unit of Measure Code",  "Unit of Measure Code") ;
            PurchLine."Unit of Measure Code" := "Unit of Measure Code";
            PurchLine."Location Code" := "Location Code";
            PurchLine."Material Requisition" := "Material Requisitioned";
            PurchLine."FA Component Category" := "FA Component Category";
            PurchLine."Variant Code" := "Variant Code"; // VK
                                                        //>>PCPL-Sourav
            PurchLine.VALIDATE("Shortcut Dimension 1 Code", "FA Sub Category");
            PurchLine.VALIDATE("Shortcut Dimension 2 Code", "Main Category");
            //<<PCPL-Sourav
            //>>PCPL-JOB0001
            PurchLine."Job No." := "Job No.";
            PurchLine."Job Task No." := "Job Task No.";
            PurchLine."Job Planning Line No." := "Job Planning Line No.";
            //<<PCPL-JOB0001
            //CALCSUMS("PO Qty");
            CALCFIELDS("PO Qty");
            outstandqty := Quantity - "PO Qty";
            PurchLine.VALIDATE(PurchLine.Quantity, outstandqty); // Tolerance System
            PurchLine."Indent No." := "Document No.";
            PurchLine.VALIDATE(PurchLine."Indent Line No.", "Line No.");
            IF outstandqty <> 0 THEN BEGIN
                PurchLine.INSERT;
                /* //need to check dimension in nav13
                //
                DocDim.RESET;
                DocDim.SETRANGE(DocDim."Document Type",DocDim."Document Type"::Order);
                DocDim.SETRANGE(DocDim."Document No.",PurchLine."Document No.");
                DocDim.SETRANGE(DocDim."Line No.",PurchLine."Line No.");
                DocDim.SETRANGE("Dimension Code",'CA');
                  IF NOT DocDim.FINDFIRST THEN BEGIN
                  DocDim.INIT;
                  DocDim."Table ID" := 39;
                  DocDim."Document Type" := DocDim."Document Type"::Order;
                  DocDim."Document No." := PurchLine."Document No.";
                  DocDim."Line No." := PurchLine."Line No.";
                  DocDim."Dimension Code" := 'CA';
                  DocDim."Dimension Value Code" := PurchLine."Cost Allocation Dimension";
                  DocDim.INSERT;
                  END
                  */
            END ELSE BEGIN
                EXIT;
            END;

            NextLineNo := NextLineNo + 10000;
        UNTIL PurchLine.NEXT = 0;
        //PCPL-25/INCDoc
        IndentHeader.RESET;
        IndentHeader.SETRANGE("No.", "Document No.");
        IF IndentHeader.FINDFIRST THEN BEGIN
            PurchInvHeader."Incoming Document Entry No." := IndentHeader."Incoming Document Entry No.";
            PurchInvHeader.MODIFY;
        END;
        //PCPL-25/INCDoc

    end;

    procedure ShowLineComments();
    var
        ScheduleDetail: Record 50001;
        ScheduleForm: Page 50015;
    begin
        TESTFIELD("Document No.");
        TESTFIELD("Line No.");
        ScheduleDetail.SETRANGE(ScheduleDetail."Entry Type", "Entry Type");
        ScheduleDetail.SETRANGE(ScheduleDetail."Document No", "Document No.");
        ScheduleDetail.SETRANGE(ScheduleDetail."Indent Line No", "Line No.");
        ScheduleDetail.SETRANGE(ScheduleDetail.type, Type);
        ScheduleDetail.SETRANGE(ScheduleDetail.Item, "No.");
        ScheduleForm.SETTABLEVIEW(ScheduleDetail);
        ScheduleForm.RUNMODAL;
    end;

    procedure PurchaseOrderCreate();
    var
        PurchaseHeader: Record 38;
        PurchaseLine: Record 39;
        PurchasesPayablesSetup: Record 312;
        //PortalVendUpdatedPurchRec: Record 50032;
        NoSeriesManagement: Codeunit 396;
        POCreated: Boolean;
        //PortalVendUpdatedPurchRec1: Record 50032;
        RecIndentLine: Record 50003;
    begin

        //Start PCPL<<0028/Avinash
        RecIndentLine.RESET;
        RecIndentLine.SETRANGE("Vendor No.", "Vendor No.");
        RecIndentLine.SETRANGE("Document No.", "Document No.");
        RecIndentLine.SETRANGE("Create PO", TRUE);
        //RecIndentLine.SETRANGE("PO Created",FALSE);
        IF RecIndentLine.FINDFIRST THEN BEGIN
            PurchaseHeader.RESET;
            PurchaseHeader.INIT;
            PurchaseHeader.VALIDATE("Document Type", PurchaseHeader."Document Type"::Order);
            PurchasesPayablesSetup.GET;
            PurchaseHeader."No." := NoSeriesManagement.GetNextNo(PurchasesPayablesSetup."Order Nos.", 0D, TRUE);
            PurchaseHeader.VALIDATE("Buy-from Vendor No.", RecIndentLine."Vendor No.");
            PurchaseHeader.VALIDATE("Location Code", RecIndentLine."Location Code");
            PurchaseHeader."PO Created" := TRUE;
            PurchaseHeader.INSERT;
            POCreated := TRUE;
        END ELSE
            ERROR('PO Already Created ');
        //IF "PO Created" THEN BEGIN
        RecIndentLine.RESET;
        RecIndentLine.SETRANGE("Vendor No.", "Vendor No.");
        RecIndentLine.SETRANGE("Document No.", "Document No.");
        RecIndentLine.SETRANGE("Create PO", TRUE);
        IF RecIndentLine.FINDSET THEN
            REPEAT
                PurchaseLine.RESET;
                PurchaseLine.SETRANGE("Document Type", PurchaseLine."Document Type"::Order);
                PurchaseLine.SETRANGE("Document No.", PurchaseHeader."No.");
                IF PurchaseLine.FINDLAST THEN BEGIN
                    REPEAT
                        PurchaseLine.INIT;
                        PurchaseLine.VALIDATE("Document Type", PurchaseHeader."Document Type");
                        PurchaseLine.VALIDATE("Document No.", PurchaseHeader."No.");
                        PurchaseLine.VALIDATE("Buy-from Vendor No.", PurchaseHeader."Buy-from Vendor No.");
                        PurchaseLine."Line No." := PurchaseLine."Line No." + 10000;
                        PurchaseLine.VALIDATE(Type, PurchaseLine.Type::Item);
                        PurchaseLine.VALIDATE("No.", "No.");
                        PurchaseLine.VALIDATE("Location Code", RecIndentLine."Location Code");
                        PurchaseLine.VALIDATE("Direct Unit Cost", RecIndentLine."Vendor Unit_ Price");
                        PurchaseLine.VALIDATE(Quantity, RecIndentLine.Quantity);
                        PurchaseLine.VALIDATE("Indent No.", RecIndentLine."Document No.");
                        PurchaseLine.VALIDATE("Indent Line No.", RecIndentLine."Line No.");
                        PurchaseLine.INSERT;
                    UNTIL PurchaseLine.NEXT = 0;
                END ELSE BEGIN
                    PurchaseLine.INIT;
                    PurchaseLine.VALIDATE("Document Type", PurchaseHeader."Document Type");
                    PurchaseLine.VALIDATE("Document No.", PurchaseHeader."No.");
                    PurchaseLine.VALIDATE("Buy-from Vendor No.", PurchaseHeader."Buy-from Vendor No.");
                    PurchaseLine.VALIDATE("Line No.", 10000);
                    PurchaseLine.VALIDATE(Type, PurchaseLine.Type::Item);
                    PurchaseLine.VALIDATE("No.", "No.");
                    PurchaseLine.VALIDATE("Indent No.", RecIndentLine."Document No.");
                    PurchaseLine.VALIDATE("Location Code", RecIndentLine."Location Code");
                    PurchaseLine.VALIDATE("Unit Cost", RecIndentLine."Vendor Unit_ Price");
                    PurchaseLine.VALIDATE(Quantity, RecIndentLine."PO Qty");
                    PurchaseLine.VALIDATE("Indent Line No.", RecIndentLine."Line No.");
                    PurchaseLine.INSERT;
                    "PO Created" := "PO Created"::Created
                    //POCreated := TRUE;
                END;
            UNTIL RecIndentLine.NEXT = 0;
        MESSAGE('PO created' + PurchaseHeader."No.");
        PurchaseHeader.SETRANGE(PurchaseHeader."No.", PurchaseHeader."No.");
        IF PurchaseHeader.FINDFIRST THEN
            PAGE.RUN(50, PurchaseHeader);
        //END;
        /*
        PortalVendUpdatedPurchRec1.RESET;
        PortalVendUpdatedPurchRec1.SETRANGE("Selected For PO",TRUE);
        IF PortalVendUpdatedPurchRec1.FINDSET THEN REPEAT
          PortalVendUpdatedPurchRec1.VALIDATE("PO Created",TRUE);
          PortalVendUpdatedPurchRec1.MODIFY;
        UNTIL PortalVendUpdatedPurchRec1.NEXT=0;
        */

    end;
}

