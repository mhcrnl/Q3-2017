
=head2 ctkDTvar

	 Decision table

=cut

package ctkDTvar; {
## conditions
my $dec_0 = sub{'$'.main::getMW() ne $ctkProject::arg1 };
my $dec_1 = sub{main::getFile_opt->{'code'} == 0 };
my $dec_2 = sub{main::getFile_opt->{'code'} == 1 };
my $dec_3 = sub{main::getFile_opt->{'code'} == 2 || main::getFile_opt->{'code'} == 3 };
my $dec_4 = sub{main::getFile_opt->{'autoExtract2Local'} };
my $dec_5 = sub{scalar(grep($_ eq $ctkProject::arg1,@ctkProject::user_local_vars)) > 0 };
my $dec_6 = sub{scalar(grep($_ eq $ctkProject::arg1,@ctkProject::user_auto_vars)) > 0 };
## actions
my $act_0 = sub{ctkProject->insertLocal($ctkProject::arg1) };
my $act_1 = sub{ctkProject->insertGlobal($ctkProject::arg1) };
my $act_2 = sub{ctkProject->removeLocal($ctkProject::arg1) };
my $act_3 = sub{ctkProject->removeGlobal($ctkProject::arg1) };
my $act_4 = sub{push @ctkProject::DTmessage,"$ctkProject::arg2 $ctkProject::arg1" };
my $act_5 = sub{&main::Log("$ctkProject::arg2 $ctkProject::arg1") };
sub xTable {
my $rv = 0;
my @state=();
push @state,&$dec_0();
push @state,&$dec_1();
push @state,&$dec_2();
push @state,&$dec_3();
push @state,&$dec_4();
push @state,&$dec_5();
push @state,&$dec_6();
if ( $state[0] && $state[1] && !($state[2]) && !($state[3]) && $state[4] && $state[5] && $state[6] ) {
	&$act_4();
}
if ( $state[0] && $state[1] && !($state[2]) && !($state[3]) && $state[4] && $state[5] && !($state[6]) ) {
	warn 'no actions'
}
if ( $state[0] && $state[1] && !($state[2]) && !($state[3]) && $state[4] && !($state[5]) && $state[6] ) {
	&$act_0();
}
if ( $state[0] && $state[1] && !($state[2]) && !($state[3]) && $state[4] && !($state[5]) && !($state[6]) ) {
	&$act_0();
}
if ( $state[0] && $state[1] && !($state[2]) && !($state[3]) && !($state[4]) && $state[5] && $state[6] ) {
	warn 'no actions'
}
if ( $state[0] && $state[1] && !($state[2]) && !($state[3]) && !($state[4]) && $state[5] && !($state[6]) ) {
	&$act_1();&$act_4();
}
if ( $state[0] && $state[1] && !($state[2]) && !($state[3]) && !($state[4]) && !($state[5]) && $state[6] ) {
	warn 'no actions'
}
if ( $state[0] && $state[1] && !($state[2]) && !($state[3]) && !($state[4]) && !($state[5]) && !($state[6]) ) {
	&$act_1();
}
if ( $state[0] && !($state[1]) && $state[2] && !($state[3]) && $state[4] && $state[5] && $state[6] ) {
	warn 'no actions'
}
if ( $state[0] && !($state[1]) && $state[2] && !($state[3]) && $state[4] && $state[5] && !($state[6]) ) {
	warn 'no actions'
}
if ( $state[0] && !($state[1]) && $state[2] && !($state[3]) && $state[4] && !($state[5]) && $state[6] ) {
	&$act_0();&$act_4();
}
if ( $state[0] && !($state[1]) && $state[2] && !($state[3]) && $state[4] && !($state[5]) && !($state[6]) ) {
	&$act_0();
}
if ( $state[0] && !($state[1]) && $state[2] && !($state[3]) && !($state[4]) && $state[5] && $state[6] ) {
	&$act_4();
}
if ( $state[0] && !($state[1]) && $state[2] && !($state[3]) && !($state[4]) && $state[5] && !($state[6]) ) {
	&$act_1();&$act_4();
}
if ( $state[0] && !($state[1]) && $state[2] && !($state[3]) && !($state[4]) && !($state[5]) && $state[6] ) {
	warn 'no actions'
}
if ( $state[0] && !($state[1]) && $state[2] && !($state[3]) && !($state[4]) && !($state[5]) && !($state[6]) ) {
	&$act_1();
}
if ( $state[0] && !($state[1]) && !($state[2]) && $state[3] && $state[4] && $state[5] && $state[6] ) {
	warn 'no actions'
}
if ( $state[0] && !($state[1]) && !($state[2]) && $state[3] && $state[4] && $state[5] && !($state[6]) ) {
	warn 'no actions'
}
if ( $state[0] && !($state[1]) && !($state[2]) && $state[3] && $state[4] && !($state[5]) && $state[6] ) {
	&$act_0();&$act_4();
}
if ( $state[0] && !($state[1]) && !($state[2]) && $state[3] && $state[4] && !($state[5]) && !($state[6]) ) {
	&$act_0();
}
if ( $state[0] && !($state[1]) && !($state[2]) && $state[3] && !($state[4]) && $state[5] && $state[6] ) {
	&$act_4();
}
if ( $state[0] && !($state[1]) && !($state[2]) && $state[3] && !($state[4]) && $state[5] && !($state[6]) ) {
	&$act_1();&$act_4();
}
if ( $state[0] && !($state[1]) && !($state[2]) && $state[3] && !($state[4]) && !($state[5]) && $state[6] ) {
	warn 'no actions'
}
if ( $state[0] && !($state[1]) && !($state[2]) && $state[3] && !($state[4]) && !($state[5]) && !($state[6]) ) {
	&$act_1();
}
{ ## unconditional action
	&$act_5();
}
return $rv;
}
1;} ## make the compiler happy
