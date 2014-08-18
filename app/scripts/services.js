'use strict';

/* Services */

angular.module('Test.services', []).
    value('version', '0.1').
    service('messageService', ['$root', function ($rootScope) {
        return {
            change: function(value) {
                $rootScope.$broadcast('messageService.update', value);
            }
        }        
    }]).service();
