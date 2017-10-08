use threads;
use threads::shared;
use attributes;    # perl2exe

my $trace_queue;
share $trace_queue;

my $synchronous_trace : shared = 1;
my $data_thread : shared;

package Comm::Trace;
use strict;
use Data::Dump qw(dump);
use Time::HiRes qw(gettimeofday);

use IO::File;
use File::Basename;
my $base_name = fileparse($0);
my $comm_file = "tmp/${base_name}_Comm1.trc";
open( DB2, ">$comm_file" ) or die "Impossible d'ouvrir $comm_file : $!\n";
autoflush DB2;

sub TIEHANDLE {
    my ( $classe, $type ) = @_;

    my $array_ref;
    $array_ref->[0] = $type;
    bless $array_ref, $classe;
}

sub PRINT {
    my $self = shift;
    my $type = $self->[0];

    my $who = threads->tid;

    # Tra�age de l'appel dans Data mais de fa�on asynchrone
    my @calls;
    my $indice = 0;
    while ( my ( $pack, $file, $line ) = caller( $indice++ ) ) {
        push @calls, ( $pack, $file, $line );
    }
    my $array_dump = dump @calls;
    my $hash_dump  = dump(
        'who'   => $who,
        'on'    => $type,
        'calls' => $array_dump,
        'time'  => scalar(gettimeofday)
    );
    if ( $synchronous_trace and defined $data_thread ) {
        print DB2 "Print synchrone... redirection OK\n";
        Editor->trace_print( $hash_dump, @_ );
    }
    else {
        print DB2
"Print asynchrone : impossible de rediriger avec m�nage dans Data...\n";
        my $trace = Comm::encode( 'trace', $who, 'X', 'print', $hash_dump, @_ );
        $trace_queue->enqueue($trace);
    }
}

package Comm;
require Exporter;
our @ISA = ("Exporter");

#our @EXPORT= qw ( decode_message encode simple_call call_with_who create_queue get_queue get_response_from reference_worker anything_for_me get_message_for ask get_task_to_do ask2 verify_model_thread respond simple_context_call just_call_with_who);
our @EXPORT =
  qw ( simple_call call_with_who anything_for_me get_task_to_do ask2 verify_model_thread respond simple_context_call just_call_with_who verify_graphic verify_motion_thread reference_event_conditions);

use IO::File;
use File::Basename;
my $name       = fileparse($0);
my $comm2_file = "tmp/${name}_Comm2.trc";
open( DBG, ">$comm2_file" ) or die "Impossible d'ouvrir $comm2_file : $!\n";
autoflush DBG;

# Am�liorations du m�canisme ask-answer
#    Am�lioration parall�le � pr�voir (mais interne donc pas urgent) : l'appel� doit pouvoir v�rifier qu'il ne sait pas traiter la demande (eval)
#
#    Mode synchrone et asynchrone
#      Probl�me : on doit pouvoir r�cup�rer apr�s coup un statut (en erreur ?, en cours ?, termin� OK ?) d'une demande initialement asynchrone
#         Il y a donc 3 ou 4 fa�ons d'appeler les fonctions de l'�diteur :
#                 - demande synchrone avec test du code retour
#                 - demande asynchrone sans test du code retour
#                 - demande asynchrone avec test du code retour : un identifiant de requ�te doit �tre fourni � l'appelant
#                 - demande synchrone sans test du code retour
#              - on peut aussi imaginer des demandes avec r�essai activant automatiquement le d�buggage...
#         Il faut �viter de doubler toutes les fonctions et que l'interface soit facile
#
#   Interface OK :
#                             my $rc = $editor->function ( @param ) : appel synchrone implicite
#                             $editor->function ( @param )               : appel asynchrone implicite
#                             $editor->sync->function( @param )       : appel synchrone explicite
#                             my $id = $editor->async->function( @param )     : appel asynchrone explicite
#
#  Mais complexit� suppl�mentaire de l'interface ask
#    doit pouvoir g�rer un identifiant unique de requ�te dans le mode asynchrone avec contexte non vide
#    doit pouvoir �voluer sans modifier tous les appels � chaque fois
#    ==> Mode d'appel avec debug � pr�voir...

use Data::Dump qw(dump);
use Time::HiRes qw(gettimeofday);

use threads;
use Thread::Queue;
use threads::shared;

use strict;

my %queue_by_tid
  ;    # Queue de r�ponse (queue cliente : un serveur la poss�de aussi)
share(%queue_by_tid);

my %tid_of_worker;
share(%tid_of_worker);

my %server_queue_by_tid
  ; # Queue server, d'attente de t�che : un client l'a aussi car il est d'abord serveur en attente au d�part
    # lors de la cr�ation de la grappe de thread
share(%server_queue_by_tid);

my %stop_dequeue_server_queue;
share(%server_queue_by_tid);

my %synchronize
  ; # ind�fini tant que l'objet n'est pas correctement fini, 1 sinon (entr�e, unique_ref)
share(%synchronize);

sub decode_message {
    my ($message) = @_;

    return if ( !defined $message );
    return eval $message;
}

sub encode {
    my @param = @_;

    #if ( $param[0] ne 'print_encode' ) {
    #		Editor->print_encode( $param[0], $param[1] );
    #}
    return dump @param;
}

my $indice = 0;

my %com_unique;
my %object;    # Objets partag�s par un thread

sub simple_call {
    my ( $self, $sub, $call_id, $context, @param ) = @_;

    my ( $who, $id ) = split( /_/, $call_id );

    if ( !defined $self ) {
        my $unique_ref = pop @param;
        if ( defined $unique_ref ) {
            $self = $object{$unique_ref};
            if ( !defined $self ) {

                # Appel avec new_editor
                $self = $unique_ref;
            }
        }
    }
    my $response =
      simple_context_call( $self, $sub, $call_id, $context, @param );

    if ( !defined $queue_by_tid{$who} ) {
        print DBG "!!!!!!!!!!!!Pas de d�finition pour who = |$who|\n";
        print DBG "=========>  Dans simple_call : $sub $who $context\n";
        return;
    }
    my $synchronous = 0;
    $synchronous = 1 if ( length $context == 1 );
    if ($synchronous) {
        respond( $call_id, $context, @param, $response );
    }
    else {    # Appel asynchrone
        my $from = threads->tid;

# LEs traces sont synchrones donc pas de deep recursion si on revient d'une m�thode asynchrone du thread data
#if ( $from ne $data_thread or $method !~ /^trace/ ) {	        # En cas d'appel asynchrone, il faut quand m�me r�pondre, mais � Data
        if ( $synchronous_trace and defined $data_thread ) {
            Editor->trace_response( $from, $call_id, undef, gettimeofday(),
                $response );
        }
        else {
            my $trace = encode(
                'trace', $who,     'X',   'response',
                $from,   $call_id, undef, gettimeofday(),
                $response
            );
            $trace_queue->enqueue($trace);
        }

        #}
    }
}

sub respond {
    my ( $call_id, $context, @param ) = @_;

    my ( $who, $id ) = split( /_/, $call_id );

    my $response = pop @param;
    if ( $context ne 'X' ) {    # Appel asynchrone de mode trace, pas de r�ponse
            #print DBG "CALL_ID $call_id, $context, @param\n";
        $queue_by_tid{$who}->enqueue($response);
    }
    else {

        #print "Appel asynchrone d�tect�...\n";
    }
}

sub simple_context_call {
    my ( $self, $sub_ref, $call_id, $context, @param ) = @_;

    my ( $who, $id ) = split( /_/, $call_id );

    my $response;
    if ( $context eq 'A' or $context eq 'AA' ) {
        my @return = $sub_ref->( $self, @param );
        $response = dump @return;
    }
    elsif ( $context eq 'S' or $context eq 'AS' ) {
        my $return = $sub_ref->( $self, @param );
        $response = dump $return;
    }
    else {    # $context = 'V' (void) ou 'X' (asynchrone)
        $sub_ref->( $self, @param );
        $response = dump;
    }
    return $response;
}

sub just_call_with_who {
    my ( $self, $sub, $call_id, $context, @param ) = @_;

    my ( $who, $id ) = split( /_/, $call_id );

    unshift @param, $who;
    simple_context_call( $self, $sub, $who, $context, @param );
}

sub call_with_who {
    my ( $self, $sub, $call_id, $context, @param ) = @_;

    my ( $who, $id ) = split( /_/, $call_id );

    my $synchronous = 0;
    $synchronous = 1 if ( length $context == 1 );
    if ( $context eq 'A' or $context eq 'AA' ) {
        my @return = $sub->( $self, $who, @param );
        $queue_by_tid{$who}->enqueue( dump @return ) if ($synchronous);
    }
    elsif ( $context eq 'S' or $context eq 'AS' ) {
        my $return = $sub->( $self, $who, @param );
        $queue_by_tid{$who}->enqueue( dump $return ) if ($synchronous);
    }
    else {
        $sub->( $self, $who, @param );
        $queue_by_tid{$who}->enqueue(dump) if ($synchronous);
    }
}

sub create_queue {
    my ($tid) = @_;

    if ( !$queue_by_tid{$tid} ) {
        $queue_by_tid{$tid} = Thread::Queue->new;
    }
}

sub get_response_from {
    my ($tid) = @_;

    return $queue_by_tid{$tid}->dequeue;
}

sub get_queue {
    my ($tid) = @_;

    return $queue_by_tid{$tid};
}

sub reference_worker {
    my ( $tid, $ref, $type, $queue ) = @_;

    $tid_of_worker{ $ref . " " . $type } = $tid;
    $server_queue_by_tid{$tid} = $queue;
}

sub search_queue {
    my ( $ref, $type ) = @_;

    my $tid = $tid_of_worker{ $ref . " " . $type };
    return $queue_by_tid{$tid};
}

sub anything_for_me {
    my $who = threads->tid;
    return if ( defined $stop_dequeue_server_queue{$who} );
    return $server_queue_by_tid{$who}->pending;
}

sub get_message_for {
    my ( $who, $from, $method, $call_id, $context ) = @_;

    if ( length($context) == 2 ) {

        # Appel asynchrone, le simple call devra r�pondre � Data
        return $call_id;
    }

    #print DBG "File d'attente pour WHO = $who\n";
    my $data = get_queue($who)->dequeue;

    # Tra�age de l'appel dans Data mais de fa�on asynchrone
    #if ( $from ne $data_thread or $method !~ /^trace/ ) {
    if ( $method !~ /^trace/ ) {
        if ( $synchronous_trace and defined $data_thread ) {
            Editor->trace_response( $from, $call_id, $method, gettimeofday(),
                $data );
        }
        else {
            my $trace = encode(
                'trace', $who,     'X',     'response',
                $from,   $call_id, $method, gettimeofday(),
                $data
            );
            $trace_queue->enqueue($trace);
        }
    }
    return decode_message($data);
}

sub get_task_to_do {

    # Le thread serveur se bloque dans l'attente d'un nouveau travail � faire
    my $who = threads->tid;
    my $data;
    do {
        $data = $server_queue_by_tid{$who}->dequeue;
    } while ( defined $stop_dequeue_server_queue{$who} );

# Un nouveau travail a �t� d�pil� de la file d'attente
# R�initialiser ici la variable shared  � 0 : le thread recommence � travailler
# Mieux : repositionner une heure de d�part pour savoir quelle dur�e l'action va couter
# On peut associer la fonction (decode_message qui suit) pour avoir des statistiques sur les dur�es des m�thodes
#return decode_message($data);
    my ( $what, @param ) = decode_message($data);

    #if ( $who eq $data_thread and $what =~ /^trace/ ) {
    if ( $what =~ /^trace/ ) {
        return ( $what, @param );
    }
    elsif ( $synchronous_trace and defined $data_thread ) {
        Editor->trace_start( $who, $param[0], $what, gettimeofday() );
    }
    else {
        my $trace =
          encode( 'trace', $who, 'X', 'start', $who, $param[0], $what,
            gettimeofday() );    # $param[0] = $call_id
        $trace_queue->enqueue($trace);
    }
    return ( $what, @param );
}

my %method;   # Permet de trouver le serveur qui g�re une m�thode �diteur donn�e
share(%method);

# Pour �volution future
my %referenced_method
  ;           # Permet de trouver le serveur qui g�re une m�thode �diteur donn�e
share(%referenced_method);

#my %object; # R�cup�re l'objet (pour appel dans le m�me thread sans dead-lock ==> non partag�)
my %standard_call;    # M�thode centrale d'appel inter-thread (non shared)

sub ref {
    my ($self) = @_;

    return $com_unique{ refaddr $self };
}

sub set_ref {
    my ( $self, $ref ) = @_;

    return if ( !defined $ref );
    $com_unique{ refaddr $self } = $ref;
}

my $call_order = 0;

sub ask2 {
    my ( $self, $method_server_tid, @data ) = @_;

    my ( $method, $server_tid ) = split( / /, $method_server_tid );
    if ( defined $server_tid ) {
        print DBG "method_server_tid defined : $method|$server_tid\n";
        print DBG "DATA = @data\n";
    }

#print ("Dans ask 2  |", $self->file_name, "|$self|", $self->ref, "|\n") if ( $method eq 'focus' );

    my $unique_ref;
    if ( $self eq 'Editor' or $self eq 'Async_Editor' )
    {    # Appel d'une m�thode de classe
        $unique_ref = '';
    }
    else {

        #print DBG "unblessed ? $self|", CORE::ref $self, "\n";
        $unique_ref = $com_unique{ refaddr $self };

        # A virer par la suite
        if ( !defined $unique_ref ) {
            $unique_ref = $self->get_unique_ref();
            $com_unique{ refaddr $self } = $unique_ref;
        }
    }
    my $client_tid = threads->tid;

    #print "unique_ref $unique_ref, method $method\n";
    my ($package) = $method{ $unique_ref . ' ' . $method };
    if ( !defined $package ) {

#print "La m�thode $method n'est pas d�finie sp�cifiquement pour l'�diteur $unique_ref\n";
        ($package) = $method{$method};

        #if ( ! defined $package and ! defined $server_tid ) {
        if ( !defined $package )
        {    # Le package doit �tre d�fini m�me si l'on pr�cise le thread
             # ==> A un thread, correspond un et un seul package mais un package peut �tre associ� � de multiples threads
            if ( !defined $server_tid or !$server_queue_by_tid{$server_tid} ) {
                print DBG
"La m�thode $method n'est pas connue de l'objet �diteur $unique_ref\n";
                return;
            }
        }
    }

    #my $server_tid;

    #print DBG "MEthode |$method| : PAckage appel� : $package\n";

    #print DBG "method_server_tid : $method_server_tid|package $package\n";
    if ( !defined $server_tid ) {
        if ( $package =~ /^shared_method:(.*)$/ ) {

            #print "La m�thode $method est commune � tous les �diteurs\n";
            my $sub_ref = eval "\\&$1";
            return $sub_ref->( $self, @data );
        }

        if ( $package =~ /^shared_thread:(.*)$/ ) {

#print "Le serveur pour la m�thod $method est commun � tous les threads\n";
# Fournir la possibilit� d'avoir plusieurs thread serveurs commun (shared_thread:$package)
            $server_tid = $tid_of_worker{$package} if ( !defined $server_tid );
            $package    = $1;

            #print "SERVEUR Responsable 1 : $server_tid\n";
        }
        else {
            $server_tid = $tid_of_worker{ $unique_ref . " " . $package }
              if ( !defined $server_tid );

    #print "SERVEUR Responsable 2 : $server_tid, m�thode $method $unique_ref\n";
        }
    }
    print DBG "mp $method|$client_tid| |$server_tid|$self\n";
    my $context = '';

    if ( CORE::ref($self) eq 'Async_Editor' or $self eq 'Async_Editor' ) {
        print DBG "Appel asynchrone d�tect� pour la m�thode $method\n";
        $context = 'A';
    }

    if ( $client_tid == $server_tid and $context ne 'A' ) {

# Appel de m�thode standard SYNCHRONE, pour un appel asynchrone, on utilise encore la queue
#print DBG "Requ�te dans le m�me thread !!\n";
        my $object = $object{$unique_ref};
        if ( !defined $object ) {

# Optimiser en cr�ant un hachage non shared qui stocke les m�thodes au fur et � mesure
#A valider quand m�me avec Autoload...
            my $sub_get_object_ref = eval "\\&${package}::return_self";
            eval { $object = $sub_get_object_ref->($self); };
            if ($@) {
                warn
"Pas moyen de r�cup�rer l'objet pour appel inter-thread $client_tid\n";
                return;
            }
            $object{$unique_ref} = $object;
        }
        else {

            #print "Objet d�fini : $object\n";
        }

        #my $method_ref = eval "\\&${package}::$method";
        my $string     = "\\&" . $package . "::" . $method;
        my $method_ref = eval $string;

        #print "STRING $string\n";
        return $method_ref->( $object, @data );
    }

    #print DBG "SERVER _TID = $server_tid pour $method\n";
    my $queue = $server_queue_by_tid{$server_tid};

    if (wantarray) {
        $context .= 'A';
    }
    elsif ( defined(wantarray) ) {
        $context .= 'S';
    }
    else {
        $context .= 'V';
    }

    my $call_id =
      $client_tid . '_0'
      ; # Avoir toujours le client m�me si pas de trace (encode apr�s if et push)

#if ( $server_tid ne $data_thread or $method !~ /^trace/ ) { # 2 serveurs pour les traces : ne plus tester le tid :
    if ( $method !~ /^trace/ )
    {    # 2 serveurs pour les traces : ne plus tester le tid :
            # toute m�thode qui commencera par "trace" ne sera pas trac�e...
            # Tra�age de l'appel dans Data
        $call_order += 1;
        $call_id = $client_tid . '_' . $call_order;
        my @calls;
        my $indice = 0;
        while ( my ( $pack, $file, $line ) = caller( $indice++ ) ) {
            push @calls, ( $pack, $file, $line );
        }
        my @call_params = (
            $call_id, $server_tid,    $method, $unique_ref,
            $context, gettimeofday(), @calls
        );
        if ( $synchronous_trace and defined $data_thread ) {

            # Trace synchrone
            Editor->trace_call(@call_params);
        }
        else {
            my $trace =
              encode( 'trace', $client_tid, 'X', 'call', @call_params );
            $trace_queue->enqueue($trace);
        }
    }

    #push ( @data, $com_unique{ refaddr $self } ) if ( $server_tid == 0 );
    if ( $server_tid == 0 ) {
        print "Appel pour thread 0 : |$unique_ref|\n" if ( $method eq 'focus' );
        push( @data, $unique_ref );
    }
    my $message = encode( $method, $call_id, $context, @data );

    #print "APPEL $message\n";

    $queue->enqueue($message);

# Pour l'instant on ne traite pas les demandes synchrones ou asynchrones (pas de modification de who)

 # Toutes les lignes suivantes permettent de tracer rapidement tous les messages
    my @message;
    if (wantarray) {
        @message =
          get_message_for( $client_tid, $server_tid, $method, $call_id,
            $context );

        #print "Tableau ", join ('|', @message), "\n";
        return @message;
    }
    else {
        $message =
          get_message_for( $client_tid, $server_tid, $method, $call_id,
            $context );

        #print "Scalaire $message\n" if ( defined $message );
        return $message;
    }

    # Equivalence des lignes pr�c�dentes :
    return get_message_for( $client_tid, $server_tid, $method, $call_id,
        $context );
}

sub stop_server_thread {
    my ( $self, $tid ) = @_;

    my $queue   = $server_queue_by_tid{$tid};
    my $message = encode(undef);
    $queue->enqueue($message);
    threads->object($tid)->join();

# Faire le m�nage des m�thodes g�r�es par le thread ... ou changer l'interface : delete_methods serait plus facile � g�rer
# qu'arr�ter un tid donn�
}

sub create_thread {
    my ( undef, $unique_ref, $package ) = @_;

    #print "Dans create_thread : $unique_ref\n" if ( defined $unique_ref );

    my $thread =
      threads->new( \&verify_server_queue_and_wait, $unique_ref, $package );

    # On ne peut pas sortir sans �tre s�r de pouvoir s'adresser au thread cr��
    # ===> cr�ation de la file d'attente
    my $tid = $thread->tid;
    if ( !$server_queue_by_tid{$tid} ) {
        $server_queue_by_tid{$tid} = Thread::Queue->new;
    }

    #print "Cr�ation du thread $tid finie\n";
    return $tid;
}
my $model_thread : shared;

sub verify_model_thread {
    if ( !defined $trace_queue ) {
        $trace_queue = Thread::Queue->new;
    }

    # Tra�age des demandes de cr�ation (appels � la m�thode new)
    my ( $package, $filename, $line ) = caller(1);

    # Tra�age de l'appel dans Data mais de fa�on asynchrone
    my @calls;
    my $indice = 1;
    while ( my ( $pack, $file, $line ) = caller( $indice++ ) ) {
        push @calls, ( $pack, $file, $line );
    }
    my $array_dump = dump @calls;
    my $trace      =
      encode( 'trace', threads->tid, 'X', 'new', threads->tid, $array_dump );
    $trace_queue->enqueue($trace);

    return
      if ( defined $model_thread )
      ;    # La cr�ation de thread est d�j� op�rationnelle

    # Redirection des print sur STDERR et SDTOUT
    tie *STDOUT, "Comm::Trace", ('STDOUT');
    tie *STDERR, "Comm::Trace", ('STDERR');

# Maintenant, on ne peut pas rendre la main tant que la cr�ation de thread n'est pas op�rationnelle
    my $thread = threads->new( \&thread_generator );
    my $tid    = $thread->tid;

    my $queue = $server_queue_by_tid{$tid};
    while ( !$queue ) {
        $queue = $server_queue_by_tid{$tid};
    }

    $model_thread = $tid
      if ( !defined $model_thread )
      ;    # Cr�ation multi-thread possible : on n'est pas seul...
    if ( $model_thread != $tid ) {

    # Le model_thread a �t� cr�� par un autre �diteur, il faut �liminer le notre
        my $message = encode(undef);
        $queue->enqueue($message);

        $thread->join();

        # Suppression des queue (ou recyclage ?) � faire
    }
    else {
        $method{'explain_method'}       = ('shared_method:explain_method');
        $method{'empty_queue'}          = ('shared_method:empty_queue');
        $method{'create_server_thread'} =
          ('shared_method:create_server_thread');
        $method{'create_standard_server_thread'} =
          ('shared_method:create_standard_server_thread');
        $method{'create_client_thread'} =
          ('shared_method:create_client_thread');
        $method{'stop_server_thread'} = ('shared_method:stop_server_thread');
        $method{'ref'}                = ('shared_method:ref');
        $method{'set_synchronize'}    = ('shared_method:set_synchronize');
        $method{'get_synchronized'}   = ('shared_method:get_synchronized');
        $method{'redirect'}           = ('shared_method:redirect');
        $method{'transform_hash'}     = ('shared_method:transform_hash');
        $method{'set_ref'}            = ('shared_method:set_ref');

        $method{'create_thread'}             = ('shared_thread:Comm');
        $method{'add_method'}                = ('shared_method:add_method');
        $tid_of_worker{'shared_thread:Comm'} = $tid;
        create_data_thread();
    }
}

sub empty_queue {

# Arr�ter l'ex�cution de requ�tes asynchrones lorsque l'on sait qu'elles deviennent inutiles (voir eval_print)
    my ( $self, $tid ) = @_;

    #print DBG "Dans empty_queue self, tid = $self, $tid\n";
    $stop_dequeue_server_queue{$tid} = 1;
    while ( $server_queue_by_tid{$tid}->pending ) {
        my $data = $server_queue_by_tid{$tid}->dequeue;
        my ( $method, $call_id ) = decode_message($data);

# Probl�me subtil si appel en asynchrone (Async_Editor) : � d�cortiquer
#   => piste ?, le thread 2 (Data) ex�cutant "free_call_id" est aussi responsable
#                   de la r�ception des requ�tes asynchrones
#  Peut-on m�langer les appels synchrones et asynchrones vis-�-vis de ce thread ?
        Editor->free_call_id($call_id)
          ; # call_id est en attente d'ex�cution, il faut lib�rer la m�moire occup�e par Data
    }
    undef $stop_dequeue_server_queue{$tid};
}

sub create_data_thread {

# Maintenant, on ne peut pas rendre la main tant que la cr�ation de thread n'est pas op�rationnelle
    eval "use Easy::Data";

    #print DBG "EVAL de use Easy::Data : \n$@\n";
    my $tid =
      create_server_thread( undef, 'Data',
        [ 'file_of_zone', 'list_in_zone', 'print_encode' ] );

    my $queue = $server_queue_by_tid{$tid};
    while ( !$queue ) {
        $queue = $server_queue_by_tid{$tid};
    }

# On met la vraie queue pour trace_queue
# On suppose que l'on est seul � travailler : premi�re demande de cr�ation d'un objet �diteur
# ======>  donc pas possible de faire d�s maintenant un appel de m�thode (� v�rifier)
    while ( $trace_queue->pending ) {
        my $data = $trace_queue->dequeue;
        $queue->enqueue($data);
    }
    $trace_queue = $queue;

    $method{'find_in_zone'}     = ('shared_thread:Data');
    $method{'list_in_zone'}     = ('shared_thread:Data');
    $method{'reference_editor'} = ('shared_thread:Data');

    #$method{'print_encode'} = ( 'shared_thread:Data' );
    $method{'file_name_of_zone_order'}        = ('shared_thread:Data');
    $method{'name_of_zone_order'}             = ('shared_thread:Data');
    $method{'data_file_name'}                 = ('shared_thread:Data');
    $method{'data_name'}                      = ('shared_thread:Data');
    $method{'trace_print'}                    = ('shared_thread:Data');
    $method{'trace_call'}                     = ('shared_thread:Data');
    $method{'trace_start'}                    = ('shared_thread:Data');
    $method{'trace_response'}                 = ('shared_thread:Data');
    $method{'async_status'}                   = ('shared_thread:Data');
    $method{'async_response'}                 = ('shared_thread:Data');
    $method{'reference_print_redirection'}    = ('shared_thread:Data');
    $method{'size_self_data'}                 = ('shared_thread:Data');
    $method{'free_call_id'}                   = ('shared_thread:Data');
    $method{'print_thread_list'}              = ('shared_thread:Data');
    $method{'data_get_editor_from_name'}      = ('shared_thread:Data');
    $method{'data_get_editor_from_file_name'} = ('shared_thread:Data');
    $method{'data_substitute_eval_with_file'} = ('shared_thread:Data');
    $method{'reference_zone'}                 = ('shared_thread:Data');
    $method{'zone_named'}                     = ('shared_thread:Data');
    $method{'zone_list'}                      = ('shared_thread:Data');

    $tid_of_worker{'shared_thread:Data'} = $tid;
    $data_thread = $tid;

    $method{'test'}                 = ('shared_thread:Abstract');
    $method{'insert'}               = ('shared_thread:Abstract');
    $method{'enter'}                = ('shared_thread:Abstract');
    $method{'erase'}                = ('shared_thread:Abstract');
    $method{'change_title'}         = ('shared_thread:Abstract');
    $method{'bind_key'}             = ('shared_thread:Abstract');
    $method{'wrap'}                 = ('shared_thread:Abstract');
    $method{'display'}              = ('shared_thread:Abstract');
    $method{'empty'}                = ('shared_thread:Abstract');
    $method{'deselect'}             = ('shared_thread:Abstract');
    $method{'eval'}                 = ('shared_thread:Abstract');
    $method{'save_search'}          = ('shared_thread:Abstract');
    $method{'focus'}                = ('shared_thread:Abstract');
    $method{'on_top'}               = ('shared_thread:Abstract');
    $method{'reference_zone_event'} = ('shared_thread:Abstract');

    $referenced_method{'test'}         = ('I|0||Abstract');
    $referenced_method{'insert'}       = ('I|0||Abstract');
    $referenced_method{'enter'}        = ('I|0||Abstract');
    $referenced_method{'erase'}        = ('I|0||Abstract');
    $referenced_method{'change_title'} = ('I|0||Abstract');
    $referenced_method{'bind_key'}     = ('I|0||Abstract');
    $referenced_method{'wrap'}         = ('I|0||Abstract');
    $referenced_method{'display'}      = ('I|0||Abstract');
    $referenced_method{'empty'}        = ('I|0||Abstract');
    $referenced_method{'deselect'}     = ('I|0||Abstract');
    $referenced_method{'eval'}         = ('I|0||Abstract');
    $referenced_method{'save_search'}  = ('I|0||Abstract');
    $referenced_method{'focus'}        = ('I|0||Abstract');
    $referenced_method{'on_top'}       = ('I|0||Abstract');

    $method{'abstract_size'} = ('shared_thread:Abstract');

    $method{'new_editor'}         = ('shared_thread:Abstract');
    $method{'editor_insert_mode'} = ('shared_thread:Abstract');
    $method{'editor_set_insert'}  = ('shared_thread:Abstract');
    $method{'editor_set_replace'} = ('shared_thread:Abstract');

    $method{'screen_first'}        = ('shared_thread:Abstract');
    $method{'screen_last'}         = ('shared_thread:Abstract');
    $method{'screen_number'}       = ('shared_thread:Abstract');
    $method{'screen_font_height'}  = ('shared_thread:Abstract');
    $method{'screen_height'}       = ('shared_thread:Abstract');
    $method{'screen_y_offset'}     = ('shared_thread:Abstract');
    $method{'screen_x_offset'}     = ('shared_thread:Abstract');
    $method{'screen_line_height'}  = ('shared_thread:Abstract');
    $method{'screen_margin'}       = ('shared_thread:Abstract');
    $method{'screen_width'}        = ('shared_thread:Abstract');
    $method{'screen_set_width'}    = ('shared_thread:Abstract');
    $method{'screen_set_height'}   = ('shared_thread:Abstract');
    $method{'screen_set_x_corner'} = ('shared_thread:Abstract');
    $method{'screen_set_y_corner'} = ('shared_thread:Abstract');
    $method{'screen_move'}         = ('shared_thread:Abstract');
    $method{'screen_wrap'}         = ('shared_thread:Abstract');
    $method{'screen_set_wrap'}     = ('shared_thread:Abstract');
    $method{'screen_unset_wrap'}   = ('shared_thread:Abstract');

    $method{'display_text'}             = ('shared_thread:Abstract');
    $method{'display_next'}             = ('shared_thread:Abstract');
    $method{'display_previous'}         = ('shared_thread:Abstract');
    $method{'display_next_is_same'}     = ('shared_thread:Abstract');
    $method{'display_previous_is_same'} = ('shared_thread:Abstract');
    $method{'display_number'}           = ('shared_thread:Abstract');
    $method{'display_ord'}              = ('shared_thread:Abstract');
    $method{'display_height'}           = ('shared_thread:Abstract');
    $method{'display_abs'}              = ('shared_thread:Abstract');
    $method{'display_select'}           = ('shared_thread:Abstract');

    $method{'line_displayed'} = ('shared_thread:Abstract');
    $method{'line_select'}    = ('shared_thread:Abstract');

    $method{'cursor_position_in_display'} = ('shared_thread:Abstract');
    $method{'cursor_position_in_text'}    = ('shared_thread:Abstract');
    $method{'cursor_abs'}                 = ('shared_thread:Abstract');
    $method{'cursor_virtual_abs'}         = ('shared_thread:Abstract');
    $method{'cursor_line'}                = ('shared_thread:Abstract');
    $method{'cursor_display'}             = ('shared_thread:Abstract');
    $method{'cursor_set'}                 = ('shared_thread:Abstract');
    $method{'cursor_get'}                 = ('shared_thread:Abstract');
    $method{'cursor_make_visible'}        = ('shared_thread:Abstract');

    $method{'load_search'} = ('shared_thread:Abstract');

    $tid_of_worker{'shared_thread:Abstract'} = 0;
}

sub verify_graphic {
    my ( $hash_ref, $editor ) = @_;
    my $zone_ref = $hash_ref->{'zone'};

    #print "verify graphic : ZONE_REF $zone_ref\n";
    my $ref = refaddr $editor;
    $com_unique{$ref} = $ref;

    my $queue = $server_queue_by_tid{0};

    # V�rification de la queue serveur
    if ( !$queue ) {
        $queue = Thread::Queue->new;
        $server_queue_by_tid{0} = $queue;
    }
    reference_worker( 0, $ref, 'graphic', $queue );

    # V�rification de la queue cliente
    if ( !$queue_by_tid{0} ) {
        $queue_by_tid{0} = Thread::Queue->new;
    }

    # Pas aussi brutal : peut �tre qu'il y a d�j� "examine..." qui fonctionne
    my $tid = threads->tid;

    if ( $tid == 0 ) {
        use Easy::Abstract;
        my $object = Abstract->new( $hash_ref, $editor, $ref );
        $object{$ref} = $object;
        return $object;
    }
    else {
        my $message =
          encode( 'new_editor', threads->tid, 'S', $hash_ref, $ref );
        $server_queue_by_tid{0}->enqueue($message);
        my $answer = $queue_by_tid{ threads->tid }->dequeue;

        # L'appel de m�thode bloque, ... � voir
        #   => Tra�age correct de new_editor impossible � cause de ce blocage
        #my ( $answer ) = Editor->new_editor($hash_ref, $ref);

    }
}

sub new_editor {

# Voir "examine_external_request" et "simple_call" pour l'inversion
# En fait,  $ref joue le r�le de l' "objet" avec lequel on appelle cette m�thode
    my ( $ref, $hash_ref ) = @_;

    #print "Dans new_editor\n";
    #print "\tREF $ref\n\tREF_HASH $hash_ref\n\tRESTE $reste\n";
    my $editor = bless \do { my $anonymous_scalar }, 'Editor';
    $com_unique{ refaddr $editor } = $ref;

    #print "#### REFERENCEMENT avec $ref\n";
    reference_worker( 0, $ref, 'graphic', $server_queue_by_tid{0} );
    $editor->reference($ref);
    use Easy::Abstract;
    my $object = Abstract->new( $hash_ref, $editor, $ref );
    $object{$ref} = $object;

    # Doit �tre supprim� lorsque l'on utilisera uniquement %object
    Editor::reference_Abstract( refaddr $editor, $object );
    return ( $object, $server_queue_by_tid{0} );
}

sub create_server_thread {
    my ( $self, $package, $tab_methods_ref, @param ) = @_;

    #print "Dans la m�thode de cr�ation d'un thread serveur $package @param\n";
    #my $run_sub_ref = eval "\\&${package}::manage_requests";

    my $unique_ref;
    if ( defined $self and CORE::ref($self) ) {
        my $ref = refaddr $self;
        $unique_ref = $com_unique{$ref};
        if ( !$unique_ref ) {

# Lorsque tous les threads seront cr��s par Comm, d�clarer get_unique_ref ici et modifier ces 2 lignes
            $unique_ref = $self->get_unique_ref;

            # Mise � jour de la r�f�rence unique
            $com_unique{$ref} = $unique_ref;
        }
    }

# Mise � jour du hachage (shared) des m�thodes export�es : simples cha�nes de caract�re
# Mise � jour du hachage (shared) des m�thodes export�es : simples cha�nes de caract�re
    {
        my $prefix = '';
        if ( defined $unique_ref ) {
            $prefix = $unique_ref . ' ';
            for ( @{$tab_methods_ref} ) {

                # A revoir : param�tres en plus � donner...
                $method{ $prefix . $_ } = $package;
            }
        }
        else {
            for ( @{$tab_methods_ref} ) {

                # A revoir : param�tres en plus � donner...
                $method{ $prefix . $_ } = "shared_thread:$package";
            }
        }
    }

    my $tid = create_thread( $self, $unique_ref, $package );

  #print "tid_of_worker $unique_ref $package $tid\n" if ( defined $unique_ref );
    $tid_of_worker{ $unique_ref . ' ' . $package } = $tid
      if ( defined $unique_ref );
    $tid_of_worker{"shared_thread:$package"} = $tid if ( !defined $unique_ref );

    my $queue = $server_queue_by_tid{$tid};

    my $message =
      encode( "${package}::manage_requests", threads->tid, "S", @param );
    $queue->enqueue($message);

# Attention, le code retour devra �tre analys� en cas de probl�me : attente sur la queue cliente
# Pour l'instant, cela serait bloquant puisque thread_generator ne renvoie rien
# my $response = $queue_by_tid{threads->tid}->dequeue;
# return if ( ! defined $response );

    #print "Create_server_thread : Je renvoie $tid\n";
    return $tid;
}

sub create_standard_server_thread {
    my ( $self, $package, $tab_methods_ref, $self_server ) = @_;

#print "Dans la m�thode de cr�ation d'un thread serveur $package $self_server\n";

    my $unique_ref;
    if ( defined $self and CORE::ref($self) ) {
        my $ref = refaddr $self;
        $unique_ref = $com_unique{$ref};
        if ( !$unique_ref ) {

# Lorsque tous les threads seront cr��s par Comm, d�clarer get_unique_ref ici et modifier ces 2 lignes
            $unique_ref = $self->get_unique_ref;

            # Mise � jour de la r�f�rence unique
            $com_unique{$ref} = $unique_ref;
        }
    }

# Mise � jour du hachage (shared) des m�thodes export�es : simples cha�nes de caract�re
    {
        my $prefix = '';
        if ( defined $unique_ref ) {
            $prefix = $unique_ref . ' ';
        }
        for ( @{$tab_methods_ref} ) {

            # A revoir : param�tres en plus � donner...
            $method{ $prefix . $_ } = "shared_thread:$package";
        }
    }

    my $tid = create_thread( $self, $unique_ref, $package );

    # A revoir pour autres types de threads...
    $tid_of_worker{ $unique_ref . ' ' . $package } = $tid
      if ( defined $unique_ref );
    $tid_of_worker{"shared_thread:$package"} = $tid;

    my $queue = $server_queue_by_tid{$tid};

# Seule diff�rence avec create_server_thread : c'est comm qui contient la proc�dure manage_requests
# Tous les threads devront �tre migr�s vers cette nouvelle m�thode "standard"
    my $message =
      encode( "Comm::manage_requests", threads->tid, "S", $self_server,
        $package );
    $queue->enqueue($message);

# Attention, le code retour devra �tre analys� en cas de probl�me : attente sur la queue cliente
# Pour l'instant, cela serait bloquant puisque thread_generator ne renvoie rien
# my $response = $queue_by_tid{threads->tid}->dequeue;
# return if ( ! defined $response );

    #print "Create_server_thread : Je renvoie $tid\n";
    return $tid;
}

sub create_client_thread {

    #print "Dans la m�thode de cr�ation d'un thread client\n";
    my ( $self, $sub_name, $package ) = @_;

    my $ref        = refaddr $self;
    my $unique_ref = $com_unique{$ref};
    if ( !$unique_ref ) {

# Lorsque tous les threads seront cr��s par Comm, d�clarer get_unique_ref ici et modifier ces 2 lignes
        $unique_ref = $self->get_unique_ref;

        # Mise � jour de la r�f�rence unique
        $com_unique{$ref} = $unique_ref;
    }

#print "... m�thode de cr�ation d'un thread client : $unique_ref\n";
# Cette m�thode de top bas niveau devrait �tre masqu�e de l'interface : juste un exemple de thread "shared" entre les �diteurs
    $package = 'main' if ( !defined $package );
    my $tid = $self->create_thread( $unique_ref, $package );

    #print "TID = $tid\n";
    my $queue = $server_queue_by_tid{$tid};

    my $message =
      encode( "${package}::$sub_name", threads->tid, "S", $unique_ref,
        $package );
    $queue->enqueue($message);

# Attention, le code retour devra �tre analys� en cas de probl�me : attente sur la queue cliente
# Pour l'instant, cela serai bloquant puisque thread_generator ne renvoie rien
# my $response = $queue_by_tid{threads->tid}->dequeue;
# return if ( ! defined $response );

    return $tid;
}

sub thread_generator {
    my $tid = threads->tid;

    if ( !$server_queue_by_tid{$tid} ) {
        $server_queue_by_tid{$tid} = Thread::Queue->new;
    }
    if ( !$queue_by_tid{$tid} ) {
        $queue_by_tid{$tid} = Thread::Queue->new;
    }
    while ( my ( $what, @param ) = get_task_to_do ) {
        last if ( !defined $what );

  # La seule chose que sait faire le thread_generator, c'est g�n�rer des threads
  #print "Dans thread g�n�rator : $what|@param\n";
        simple_call( 'not_undef_but_useless', \&create_thread, @param );
    }
}

sub verify_server_queue_and_wait {
    my ( $unique_ref, $package ) = @_;

    my $tid = threads->tid;

    my $queue = $server_queue_by_tid{$tid};

    # Il ne faut pas se mettre en attente sur une file non encore cr��e
    while ( !$queue ) {
        $queue =
          $server_queue_by_tid{$tid
          }; # La cr�ation est faite en parall�le par le thread qui a cr�� celui-ci
    }

    #print "Mise en attente du thread $tid\n";
    my $data = $queue->dequeue;

    my ( $what, @param ) = decode_message($data);
    if ( defined $what ) {

        #my $package = pop @param;
        #print "PACKAGE utilis� : $package\n";
        eval "use $package" unless ( $package eq 'main' );

        #print "Evaluation du package : \n\t$@\n";
        my $sub_ref = eval "\\&$what";

        #print "Utilisation du thread $tid et appel $what ($sub_ref)\n";

# Appel par call_with_who mais seulement lorsque la file d'attente client existe (faire un while)
        if ( !$queue_by_tid{$tid} ) {
            $queue_by_tid{$tid} = Thread::Queue->new;
        }
        if ( defined $unique_ref ) {    # Thread d�di� � un �diteur
            my $editor = bless \do { my $anonymous_scalar }, "Editor";

            #print "UNIQUE REF : $unique_ref\n";

            $com_unique{ refaddr $editor } = $unique_ref;
            $editor->reference($unique_ref);

            #print "PARAM @param|", scalar(@param), "\n";

  # Attention l'instruction qui suit doit �tre mise dans un eval
  # En cas d'�chec il faut sortir avec undef et renvoyer cela au thead demandeur
            shift @param;
            shift @param;
            $sub_ref->( $editor, @param );
        }
        else {    # Thread partag� entre tous les �diteurs
            shift @param;
            shift @param;

            #if ( $what eq 'Motion::manage_requests' ) {
            #        use Motion;
            #        Motion::manage_requests(@param);
            #}
            #else {
            $sub_ref->(@param);

            #}
        }

        #print "Dans Comm, mort du thread $tid\n";
    }
}

sub set_synchronize {
    my ($self) = @_;

    my $unique_ref = $com_unique{ refaddr $self };
    $synchronize{$unique_ref} = 1;
}

sub get_synchronized {
    my ($self) = @_;

    my $unique_ref = $com_unique{ refaddr $self };
    while ( !$synchronize{$unique_ref} ) {
    }
}

my %redirect = do "Easy/Data/Events.pm";

my $motion_thread : shared;

sub verify_motion_thread {
    my ( $unique_ref, $hash_ref ) = @_;

    my $motion_thread_useful = 0;
    my %event                = ();

    #print "DANS VERIFY MOTION THREAD...$unique_ref|$motion_ref\n";
    #print DBG "Taille de \%event $unique_ref 0 :", scalar(%event), "\n";
    for my $event ( keys %$hash_ref ) {

        #print DBG "HASH_REF pour : $event ...\n";
        if ( $redirect{$event} ) {

            #print DBG "$event est un �v�nement !\n";
            my $event_ref = $hash_ref->{$event};
            if ( $event_ref->{'mode'} eq 'async' ) {

                #print DBG "Il est asynchrone !!!\n";
                $motion_thread_useful = 1;
                $event{$event} = $event_ref;

                #print DBG "Event trouv� pour $unique_ref : $event ...\n";
            }

            #print "COND CREATION $event $event_ref->{'only'} \n";
            #$redirect_condition{$event}{$unique_ref} = $event_ref->{'only'};
        }
    }

    #print DBG "Taille de \%event $unique_ref :", scalar(%event), "\n";
    if ( !defined $motion_thread and $motion_thread_useful ) {
        eval "use Easy::Motion";

       #my $tid = create_server_thread ( undef, 'Motion', ['reference_event'] );

        my $tid =
          Editor->create_standard_server_thread( "Motion", ['reference_event'],
            {} );

        my $queue = $server_queue_by_tid{$tid};
        while ( !$queue ) {
            $queue = $server_queue_by_tid{$tid};
        }

        $motion_thread = $tid
          if ( !defined $motion_thread )
          ;    # Cr�ation multi-thread possible : on n'est pas seul...
        if ( $motion_thread != $tid ) {

    # Le model_thread a �t� cr�� par un autre �diteur, il faut �liminer le notre
            my $message = encode(undef);
            $queue->enqueue($message);

            threads->object($tid)->join();

            # Suppression des queue (ou recyclage ?) � faire
        }
    }

# Demande asynchrone de prise en compte de sub motion : cette demande ne devrait pas �tre asynchrone !!
#print "TID DU MOTION THREAD $motion_thread\n";
#print DBG "Taille de \%event $unique_ref 2 :", scalar(%event), "\n";
    for my $event ( keys %event ) {

#async_call ($motion_thread, 'reference_event', $event, $unique_ref, $event{$event} );
        print DBG "Avant call de reference event $unique_ref : $event ...\n";
        Async_Editor->ask2( 'reference_event' . ' ' . $motion_thread,
            $event, $unique_ref, $event{$event} );

#my $call_id = Async_Editor->ask2 ('reference_event', $event, $unique_ref, $event{$event} );
#print DBG "Apr�s call de reference event... \n";
    }
}

my %redirect_condition;

sub reference_event_conditions {    # Toujours ex�cut� dans le thread 0
    my ( $unique_ref, $hash_ref ) = @_;

    my %event;
    my $motion_thread_useful;

    #print "DANS VERIFY MOTION THREAD...$unique_ref|$motion_ref\n";
    for my $event ( keys %$hash_ref ) {
        if ( $redirect{$event} ) {
            my $event_ref = $hash_ref->{$event};
            if ( $event_ref->{'mode'} eq 'async' ) {
                $motion_thread_useful = 1;
                $event{$event} = $event_ref;
            }

            #print "COND CREATION $event $event_ref->{'only'} \n";
            $redirect_condition{$event}{$unique_ref} = $event_ref->{'only'};
        }
    }
}

sub redirect {
    my ( $self, $method, $abstract_ref, $hash_ref ) = @_;

    my $ref = $com_unique{ refaddr $self};
    if ( CORE::ref($method) ne 'CODE' ) {

        #print DBG "Appel asynchrone avec la m�thode $method, $ref...\n";
        if ( my $condition = $redirect_condition{$method}{$ref} ) {
            my $origin     = $hash_ref->{'origin'};
            my $sub_origin = $hash_ref->{'sub_origin'};

            #print "CONDITION : $condition\n\t$origin\n\t$sub_origin\n";
            if ( eval "$condition" ) {

                #print "\tCondition positive : $@\n";
                #async_call ($motion_thread, $method, $self->ref, $hash_ref );
                print( "dans REDIRECT de cOMM : zone = ",
                    $hash_ref->{'zone'}, "\n" )
                  if ( defined $hash_ref->{'zone'} );
                Async_Editor->ask2( 'manage_events ' . $motion_thread,
                    $method, $ref, $hash_ref );
                return;    # Garder un context Void sur "manage_event"
            }
            else {

                #print "\tFAUX (condition) : $@\n";
            }
        }
        else {             # Pas de condition, on ex�cute tout le temps
                #async_call ($motion_thread, $method, $self->ref, $hash_ref );
            Async_Editor->ask2( 'manage_events ' . $motion_thread,
                $method, $ref, $hash_ref );
            return;    # Garder un context Void sur "manage_event"
        }
    }
    else {
        eval {
            $method->(
                $self, transform_hash( $self, $abstract_ref, $hash_ref )
            );
        };
        print DBG $@ if ($@);
    }
}

sub transform_hash {
    my ( $editor, $abstract_ref, $hash_ref ) = @_;

    my $ref_line = $hash_ref->{'line'};
    if ( defined $ref_line ) {
        my $line = Line->new( $editor, $ref_line, );
        $hash_ref->{'line'} = $line;
    }
    my $ref_display = $hash_ref->{'display'};
    if ( defined $ref_display ) {
        my $display = Display->new( $editor, $ref_display, );
        $hash_ref->{'display'} = $display;
    }

    #print "Dans transform hash\n";
    #print "Fin de line size\n";
    return $hash_ref;
}

my %ref_sub;

sub manage_requests {
    my ( $self_server, $package ) = @_
      ; # L'�diteur va �tre envoy� lors de chaque requ�te (sous la forme de l'identifiant unique)

    #package $package;
    while ( my ( $what, @param ) = get_task_to_do ) {
        if ( !$ref_sub{$what} ) {
            my $ref_sub = eval "\\&${package}::$what";
            $ref_sub{$what} = $ref_sub;
            simple_call( $self_server, $ref_sub{$what}, @param );
        }
        else {
            simple_call( $self_server, $ref_sub{$what}, @param );
        }
    }
}

sub explain_method {
    my ( $self, $method ) = @_;

    print "Dans explain_method : $self, $method\n";
    if ( my $tab_ref = $referenced_method{$method} ) {
        print "  M�thode $method r�f�renc�e\n  => $tab_ref\n";
        my ( $type, $server_tid, $thread_label, $package, $translation ) =
          split( /\|/, $tab_ref );
        if ( $type eq 'I' ) {
            print "   m�thode de l'interface\n";
        }
        elsif ( $type eq 'H' ) {
            print "   m�thode cach�e\n";
        }
        else {
            print "   m�thode complexe : $type\n";
        }
    }
    else {
        print "  M�thode $method non r�f�renc�e\n";
    }
}

sub add_method {
    my ( $self, $method, $options_ref ) = @_;

    # Add method without thread association
    # ==> the method will be executed by the calling thread itself
    return if ( !defined $method );

    my $key;

    #if ( $options_ref->{'use'}
    my $package = 'main' || $options_ref->{'package'};
    my $name = $options_ref->{'sub'} || $method;

    #my $name = $method;
    #$name = $options_ref->{'sub'} if ( defined $options_ref->{'sub'} );
    if ( CORE::ref $self ) {

        # instance method (adding it for only one Editor object)
        print "Adding method $method to object $self\n";
        $key = $self->ref . ' ' . $method;
    }
    else {

        # class method (adding it for all Editor objects)
        print "Adding method $method to all Editor objects\n";
        $key = $method;
    }
    $method{$key} = "shared_method:${package}::$name";
}

1;
