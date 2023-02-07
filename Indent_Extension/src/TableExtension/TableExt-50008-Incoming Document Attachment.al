tableextension 50008 Incoming_Doc_attach extends "Incoming Document Attachment"
{
    // version NAVW19.00.00.47042,pcpl0024_Inc_Doc,//PCPLTDS194Q,PCPL-25/INCDoc,PCPL/FinishedProd/INCDoc

    fields
    {


    }


    procedure NewAttachmentFromIndentDocument(IndentHeader: Record "Indent Header")
    begin
        //PCPL-25/INCDoc
        NewAttachmentFromDocument(
    IndentHeader."Incoming Document Entry No.",
    DATABASE::"Indent Header",
    7,
    IndentHeader."No.");
    end;
    //PCPL-25/INCDoc



    var
        Vendor: Record 23;
        Customer: Record 18;
}

