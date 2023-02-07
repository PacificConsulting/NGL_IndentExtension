table 50030 "Purchaser Approval Lines"
{
    // version RSPL/INDENT/V3/001

    // Author        Code      Documentation
    // Venkatesh     VK001     To print Description of variant code
    // Nandesh       NG001     To List Items according to category selected on Indent Header


    fields
    {
        field(1; "Entry No"; Integer)
        {
        }
        field(3; "Line No."; Integer)
        {
            Editable = false;
        }
        field(4; Date; Date)
        {
            TableRelation = "Indent Header".Date;
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
        }
        field(7; "Location Code"; Code[20])
        {
            TableRelation = Location.Code;
        }
        field(8; Quantity; Decimal)
        {
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
        field(22; Remark; Text[250])
        {
        }
        field(23; "USER ID"; Text[30])
        {
            Editable = false;
        }
        field(24; "FA Component Category"; Code[20])
        {
            //TableRelation = test3.test;
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
                IF RecVar.FINDFIRST THEN
                    Description := RecVar.Description
                ELSE
                    IF Item.GET("No.") THEN
                        Description := Item.Description;

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
        }
        field(51; "Mail Already Sent"; Boolean)
        {
        }
    }

    keys
    {
        key(Key1; "Entry No")
        {
        }
        key(Key2; "Location Code", "No.")
        {
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
        "USER ID" := USERID;
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
        PurchaseLinesForm: Page "Purchase Lines";
        RecVar: Record 5401;
        IH: Record 50002;
        ITM: Record 27;
        GL: Record 15;
        RFA: Record 5600;
        FSC: Record 5608;
        Vend: Record 23;
}

