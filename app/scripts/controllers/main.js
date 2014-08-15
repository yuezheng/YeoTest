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
      {'title': 'HTML5 Boilerplate',
       'content': 'HTML5 Boilerplate is a professional front-end template for building fast, robust, and adaptable web apps or sites.'},
      {'title': 'AngularJS',
       'content': 'AngularJS is a toolset for building the framework most suited to your application development.'},
      {'title': 'Karma',
       'content': 'Spectacular Test Runner for JavaScript.'}
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
