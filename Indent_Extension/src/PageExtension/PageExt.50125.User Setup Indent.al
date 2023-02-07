pageextension 50125 User_Setup_Indent extends "User Setup" //OriginalId
{
    layout
    {
        addafter("User ID")
        {
            field("Indent Approver"; "Indent Approver")
            {
                ApplicationArea = all;

            }
            field("Indent Releaser"; "Indent Releaser")
            {
                ApplicationArea = all;
            }
            field(Substitute; Substitute)
            {
                ApplicationArea = all;
            }
            field("Approver ID"; "Approver ID")
            {
                ApplicationArea = all;
            }
            field("Approval Administrator"; "Approval Administrator")
            {
                ApplicationArea = all;
            }
        }
    }

    actions
    {
    }
}