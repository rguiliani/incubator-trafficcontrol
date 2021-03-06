/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

var FormNewDeliveryServiceController = function(deliveryService, type, types, $scope, $controller, deliveryServiceService) {

	var filteredTypes = _.filter(types, function(currentType) {
		return currentType.name.indexOf(type) != -1;
	});

	var setDNSTtl = function() {
		if (type.indexOf('HTTP') != -1) {
			deliveryService.ccrDnsTtl = 3600;
		} else {
			deliveryService.ccrDnsTtl = 30;
		}
	};
	setDNSTtl();

	// extends the FormDeliveryServiceController to inherit common methods
	angular.extend(this, $controller('FormDeliveryServiceController', { deliveryService: deliveryService, types: filteredTypes, $scope: $scope }));

	$scope.deliveryServiceName = 'New';

	$scope.settings = {
		isNew: true,
		saveLabel: 'Create'
	};

	$scope.save = function(deliveryService) {
		deliveryServiceService.createDeliveryService(deliveryService);
	};

};

FormNewDeliveryServiceController.$inject = ['deliveryService', 'type', 'types', '$scope', '$controller', 'deliveryServiceService'];
module.exports = FormNewDeliveryServiceController;
