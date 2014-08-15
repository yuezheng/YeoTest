'use strict';

/**
 * @ngdoc function
 * @name testApp.controller:MainCtrl
 * @description
 * # MainCtrl
 * Controller of the testApp
 */
angular.module('testApp')
  .controller('MainCtrl', function ($scope) {
    $scope.awesomeThings = [
      'HTML5 Boilerplate',
      'AngularJS',
      'Karma'
    ];

    var ll = [
      {'id': 1, 'name': 'aaa'},
      {'id': 2, 'name': 'aaa'},
      {'id': 3, 'name': 'bbb'},
      {'id': 4, 'name': 'bbb'}
    ];
    var aList = _.groupBy(ll, 'name');
    console.log(aList);
  });
