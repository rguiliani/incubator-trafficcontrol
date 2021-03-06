package API::DeliveryService::SteeringTarget;
#
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#
#

use UI::Utils;

use Mojo::Base 'Mojolicious::Controller';
use Data::Dumper;
use JSON;
use MojoPlugins::Response;
use Validate::Tiny ':all';

sub index {
	my $self        = shift;
	my $steering_id = $self->param('id');
	my @data;

	my %criteria;
	$criteria{'deliveryservice'} = $steering_id;

	my $steering_targets = $self->db->resultset('SteeringTarget')->search( \%criteria, { prefetch => [ 'deliveryservice', 'target', 'type' ] } );
	while ( my $row = $steering_targets->next ) {
		push(
			@data, {
				"deliveryServiceId" => $row->deliveryservice->id,
				"deliveryService"   => $row->deliveryservice->xml_id,
				"targetId"          => $row->target->id,
				"target"            => $row->target->xml_id,
				"value"             => $row->value,
				"typeId"            => $row->type->id,
				"type"              => $row->type->name,
			}
		);
	}
	$self->success( \@data );
}

sub show {
	my $self        = shift;
	my $steering_id = $self->param('id');
	my $target_id   = $self->param('target_id');

	my %criteria;
	$criteria{'deliveryservice'} = $steering_id;
	$criteria{'target'}          = $target_id;

	my $steering_target = $self->db->resultset('SteeringTarget')->search( \%criteria, { prefetch => [ 'deliveryservice', 'target', 'type' ] } );
	my @data;
	while ( my $row = $steering_target->next ) {
		push(
			@data, {
				"deliveryServiceId" => $row->deliveryservice->id,
				"deliveryService"   => $row->deliveryservice->xml_id,
				"targetId"          => $row->target->id,
				"target"            => $row->target->xml_id,
				"value"             => $row->value,
				"typeId"            => $row->type->id,
				"type"              => $row->type->name,
			}
		);
	}
	$self->success( \@data );
}

sub update {
	my $self           = shift;
	my $steering_ds_id = $self->param('id');
	my $target_ds_id   = $self->param('target_id');
	my $params         = $self->req->json;

	if ( !&is_admin($self) ) {
		return $self->forbidden();
	}

	my ( $is_valid, $result ) = $self->is_target_valid($params);

	if ( !$is_valid ) {
		return $self->alert($result);
	}

	my %criteria;
	$criteria{'deliveryservice'} = $steering_ds_id;
	$criteria{'target'}          = $target_ds_id;

	my $steering_target = $self->db->resultset('SteeringTarget')->search( \%criteria )->single();
	if ( !defined($steering_target) ) {
		return $self->not_found();
	}

	my $values = {
		deliveryservice => $params->{deliveryServiceId},
		target          => $params->{targetId},
		value           => $params->{value},
		type            => $params->{typeId},
	};

	my $update = $steering_target->update($values);

	if ($update) {

		my $response;
		$response->{deliveryServiceId} = $params->{deliveryServiceId};
		$response->{targetId}          = $params->{targetId};
		$response->{value}             = $params->{value};
		$response->{typeId}            = $params->{typeId};

		&log( $self, "Updated steering target [ " . $target_ds_id . " ] for deliveryservice: " . $steering_ds_id, "APICHANGE" );

		return $self->success( $response, "Delivery service steering target update was successful." );
	}
	else {
		return $self->alert("Delivery service steering target update failed.");
	}

}

sub create {
	my $self   = shift;
	my $params = $self->req->json;

	if ( !&is_admin($self) ) {
		return $self->forbidden();
	}

	my ( $is_valid, $result ) = $self->is_target_valid($params);

	if ( !$is_valid ) {
		return $self->alert($result);
	}

	my %criteria;
	$criteria{'deliveryservice'} = $params->{deliveryservice};
	$criteria{'target'}          = $params->{target};

	my $existing = $self->db->resultset('SteeringTarget')->search( \%criteria )->single();
	if ( defined($existing) ) {
		return $self->alert('Steering target already exists');
	}

	my $values = {
		deliveryservice => $params->{deliveryServiceId},
		target          => $params->{targetId},
		value           => $params->{value},
		type            => $params->{typeId},
	};

	my $insert = $self->db->resultset('SteeringTarget')->create($values)->insert();
	if ($insert) {
		my @response;
		push( @response, {
				deliveryServiceId => $insert->deliveryservice->id,
				targetId          => $insert->target->id,
				value           => $insert->value,
				typeId            => $insert->type->id,
			} );

		&log( $self, "Created steering target [ '" . $params->{targetId} . "' ] for delivery service: " . $params->{deliveryServiceId}, "APICHANGE" );

		return $self->success( \@response, "Delivery service target creation was successful." );
	}
	else {
		return $self->alert("Delivery service target creation failed.");
	}

}

sub delete {
	my $self           = shift;
	my $steering_ds_id = $self->param('id');
	my $target_ds_id   = $self->param('target_id');

	if ( !&is_admin($self) ) {
		return $self->forbidden();
	}

	my $target = $self->db->resultset('SteeringTarget')->search( { deliveryservice => $steering_ds_id, target => $target_ds_id } )->single();
	if ( !defined($target) ) {
		return $self->not_found();
	}

	my $delete = $target->delete();
	if ($delete) {

		&log( $self, "Deleted steering target [ " . $target_ds_id . " ] for deliveryservice: " . $steering_ds_id, "APICHANGE" );

		return $self->success_message("Delivery service target delete was successful.");
	}
	else {
		return $self->alert("Delivery service target delete failed.");
	}

}

sub is_target_valid {
	my $self   = shift;
	my $params = shift;

	if ( !$self->is_valid_target_type( $params->{typeId} ) ) {
		return ( 0, "Invalid target type" );
	}

	my $rules = {
		fields => [qw/deliveryServiceId targetId value typeId/],

		# Validation checks to perform
		checks => [
			deliveryServiceId => [ is_required("is required") ],
			targetId          => [ is_required("is required") ],
			value             => [ is_required("is required") ],
			typeId            => [ is_required("is required") ],
		]
	};

	# Validate the input against the rules
	my $result = validate( $params, $rules );

	if ( $result->{success} ) {
		return ( 1, $result->{data} );
	}
	else {
		return ( 0, $result->{error} );
	}
}

sub is_valid_target_type {
	my $self    = shift;
	my $type_id = shift;

	my $rs = $self->db->resultset("Type")->find( { id => $type_id } );
	if ( defined($rs) && ( $rs->use_in_table eq "steering_target" ) ) {
		return 1;
	}
	return 0;
}

1;
