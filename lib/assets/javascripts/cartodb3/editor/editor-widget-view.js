var cdb = require('cartodb-deep-insights.js');
var template = require('./editor-widget.tpl');
var WidgetsFormContentView = require('./widgets-form/widgets-form-content-view');

/**
 * View for an individual widget definition.
 */
module.exports = cdb.core.View.extend({

  tagName: 'li',

  events: {
    'click .js-remove': '_onRemove',
    'click .js-edit': '_onEdit'
  },

  initialize: function (opts) {
    if (!opts.tableModel) throw new Error('tableModel is required');
    this._tableModel = opts.tableModel;
    this.listenToOnce(this.model, 'destroy', this._onDestroy);
  },

  render: function () {
    this.$el.html(template({
      title: this.model.get('title')
    }));
    return this;
  },

  _onEdit: function () {
    var view = new WidgetsFormContentView({
      widgetDefinitionModel: this.model,
      tableModel: this._tableModel
    });
    this.$el.append(view.render().$el);
  },

  _onRemove: function () {
    this.model.destroy();
  },

  _onDestroy: function () {
    this.clean();
  }
});
