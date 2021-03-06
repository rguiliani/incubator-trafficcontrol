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

module.exports = angular.module('trafficPortal.private.monitor.dashboard.view', [])
	.config(function($stateProvider, $urlRouterProvider) {
		$stateProvider
			.state('trafficPortal.private.monitor.dashboard.view', {
				url: '',
				views: {
					cacheGroupsContent: {
						templateUrl: 'common/modules/widget/cacheGroups/widget.cacheGroups.tpl.html',
						controller: 'WidgetCacheGroupsController',
						resolve: {
							cacheGroupHealth: function() {
								// this is already defined in a parent template that shares the $scope
								return null;
							}
						}
					},
					capacityContent: {
						templateUrl: 'common/modules/widget/capacity/widget.capacity.tpl.html',
						controller: 'WidgetCapacityController'
					},
					cdnChartContent: {
						templateUrl: 'common/modules/widget/cdnChart/widget.cdnChart.tpl.html',
						controller: 'WidgetCDNChartController',
						resolve: {
							cdn: function() {
								// the controller will take care of fetching the cdn
								return null;
							}
						}
					},
					changeLogsContent: {
						templateUrl: 'common/modules/widget/changeLogs/widget.changeLogs.tpl.html',
						controller: 'WidgetChangeLogsController',
						resolve: {
							changeLogs: function(changeLogService) {
								return changeLogService.getChangeLogs({ limit: 5 });
							}
						}
					},
					routingContent: {
						templateUrl: 'common/modules/widget/routing/widget.routing.tpl.html',
						controller: 'WidgetRoutingController',
						resolve: {
							routing: function() {
								return [];
							}
						}
					},
				}
			})
		;
		$urlRouterProvider.otherwise('/');
	});
