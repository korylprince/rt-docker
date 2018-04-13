# don't send if user makes self owner
if ($self->TicketObj->Owner == $self->TransactionObj->Creator) {
    $RT::Logger->info('Not sending notification SMS - Creator made change');
    return 1;
}

# load ticket info
my $Ticket = $self->TicketObj;
my $Requestor = $Ticket->RequestorAddresses;
my $Subject = $Ticket->Subject;
my $url = "${\$RT::WebURL}m/ticket/show?id=${\$Ticket->Id}";
my $content = $Ticket->Transactions->First->Content();
my $sms_content = "Ticket assigned:\n$Requestor - $Subject:\n$content";

# load ticket owner
my $user = RT::User->new($RT::SystemUser);
$user->Load($Ticket->Owner);

# don't send if mobile number not set
if ( !$user->MobilePhone ) {
    $RT::Logger->info("Not sending SMS to ${\$user->RealName}: no mobile number found.");
    return 1;
}

# log sending SMS
$RT::Logger->info("Sending Assignment SMS to ${\$user->RealName} (${\$user->MobilePhone}): \"$Subject\" (#${\$Ticket->id}) requested by $Requestor");

# run the command
my $command = "/send-sms -to \"${\$user->MobilePhone}\" -url \"$url\" <<EOF\n$sms_content\nEOF";

my $output = qx($command);
my $status = $? >> 8;

# if sending SMS failed, log error
if ($status != 0) {
    $RT::Logger->warn("Error sending SMS (#${\$Ticket->id}): $output");
    $Ticket->Comment(Content=>"Sending SMS to ${\$user->RealName} (${\$user->MobilePhone}) failed. Please contact your admin, they can find more details in the logs.");
}

return 1;
