# load ticket info
my $Ticket = $self->TicketObj;
my $Requestor = $Ticket->RequestorAddresses;
my $Subject = $Ticket->Subject;
my $url = "${\$RT::WebURL}m/ticket/show?id=${\$Ticket->Id}";
my $content = $Ticket->Transactions->First->Content();
my $sms_content = "New ${\$Ticket->QueueObj->Name} Ticket:\n$Requestor - $Subject:\n$content";

# load Queue Manager role
my $custom_role = RT::CustomRole->new(RT->SystemUser);
$custom_role->Load('Queue Manager');
my $role = $Ticket->QueueObj->RoleGroup($custom_role->GroupType);

# check if role exists for queue
if (!$role->Instance) {
    return 1;
}

my $user = RT::User->new(RT->SystemUser);

# send SMS to each Queue Manager
my $members = $role->MembersObj->ItemsArrayRef;
for my $member (@$members) {
    $user->Load($member->MemberId);

    # don't send if mobile number not set
    if ( !$user->MobilePhone ) {
        $RT::Logger->info("Not sending SMS to ${\$user->RealName}: no mobile number found.");
        return 1;
    }

    # log sending SMS
    $RT::Logger->info("Sending New Ticket SMS to ${\$user->RealName} (${\$user->MobilePhone}): \"$Subject\" (#${\$Ticket->id}) requested by $Requestor");

    # run the command
    my $command = "/send-sms -to \"${\$user->MobilePhone}\" -url \"$url\" <<EOF\n$sms_content\nEOF";

    my $output = qx($command);
    my $status = $? >> 8;

    # if sending SMS failed, log error
    if ($status != 0) {
        $RT::Logger->warn("Error sending SMS (#${\$Ticket->id}): $output");
        $Ticket->Comment(Content=>"Sending SMS to ${\$user->RealName} (${\$user->MobilePhone}) failed. Please contact your admin, they can find more details in the logs.");
    }
}

return 1;
