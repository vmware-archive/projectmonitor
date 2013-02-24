// Backbone Factory JS
// https://github.com/SupportBee/Backbone-Factory

(function(){
  window.BackboneFactory = {

    factories: {},
    sequences: {},

    define: function(factory_name, klass, defaults){

      // Check for arguments' sanity
      if(factory_name.match(/[^\w_]+/)){
        throw "Factory name should not contain spaces or other funky characters";
      }

      if(defaults === undefined) defaults = function(){return {}};

      // The object creator
      this.factories[factory_name] = function(options){
        if(options === undefined) options = function(){return {}};
        arguments =  _.extend({}, {id: BackboneFactory.next("_" + factory_name + "_id")}, defaults.call(), options.call());
        return new klass(arguments);
      };

      // Lets define a sequence for id
      BackboneFactory.define_sequence("_"+ factory_name +"_id", function(n){
        return n
      });
    },

    create: function(factory_name, options){
      if(this.factories[factory_name] === undefined){
        throw "Factory with name " + factory_name + " does not exist";
      }
      return this.factories[factory_name].apply(null, [options]);
    },

    define_sequence: function(sequence_name, callback){
      this.sequences[sequence_name] = {}
      this.sequences[sequence_name]['counter'] = 0;
      this.sequences[sequence_name]['callback'] = callback;
    },

    next: function(sequence_name){
      if(this.sequences[sequence_name] === undefined){
        throw "Sequence with name " + sequence_name + " does not exist";
      }
      this.sequences[sequence_name]['counter'] += 1;
      return this.sequences[sequence_name]['callback'].apply(null, [this.sequences[sequence_name]['counter']]); //= callback;
    }
  }
})();
