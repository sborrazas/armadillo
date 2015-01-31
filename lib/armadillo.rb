require "tilt"
require "tilt/erubis"
require "delegate"

module Armadillo

  VERSION = "0.0.5"

  DEFAULT_OPTIONS = {
    :default_encoding => Encoding.default_external,
    :outvar => "@_output"
  }

  # @api private
  class TemplateContext < SimpleDelegator

    # Initialize the TemplateContext.
    #
    # @param source [Object]
    # @param template_options [Hash] ({})
    def initialize(source, template_options = {})
      @template_options = template_options
      super(source)
    end

    # Extend the specified template in which the inner view blocks will be
    # rendered.
    #
    # @note
    #   This is a template instruction.
    #
    # @param template_path [String]
    # @param locals [Hash]
    def extends(template_path, locals = {})
      @extends_data = [template_path, locals]
    end

    # Determine the contents or specify the place in which the view block will
    # be rendered.
    #
    # @note
    #   This is a template instruction.
    #
    # @param block_name [Symbol]
    # @param block [Block]
    def vlock(block_name, &block)
      raise "Invalid vlock usage" unless current_frame

      if extends?
        raise "No block given" unless block_given?

        current_frame[:vlocks][block_name] = block
      elsif (frame = get_frame(block_name, current_frame))
        temporary_frame(frame[:parent_frame]) do
          frame[:vlocks][block_name].call
        end
      elsif block_given?
        block.call
      end
    end

    # Create a new frame with previous frame as parent.
    def create_frame
      @current_frame = {
        :vlocks => {},
        :parent_frame => current_frame
      }
    end

    # Render another template with the same options as the current one.
    #
    # @param template_path [String]
    # @param locals [Hash] ({})
    #
    # @return [String]
    def render(template_path, locals = {})
      Armadillo.render(template_path, locals, @template_options)
    end

    # Determine if the current template should extend from a new template.
    #
    # @return [Boolean]
    def extends?
      !! @extends_data
    end

    # Return and delete the extract data.
    #
    # @return [Array<(String, Hash)>]
    #   The extended template name and the locals.
    def extract_extends_data
      @extends_data.tap { @extends_data = nil }
    end

    private

    # Get the current frame. Each frame contains the blocks specified using
    # #vlock and its parent frame.
    #
    # @return [Hash]
    def current_frame
      @current_frame
    end

    # Create a temporary current frame for the block to be executed.
    #
    # @param frame [Hash]
    # @param block [Block]
    def temporary_frame(frame, &block)
      old = current_frame
      @current_frame = frame
      block.call
      @current_frame = old
    end

    # Get the block from the frames stack by its name.
    #
    # @param block_name [Symbol]
    def get_frame(block_name, frame)
      if frame[:vlocks].has_key?(block_name)
        frame
      elsif frame[:parent_frame]
        get_frame(block_name, frame[:parent_frame])
      end
    end
  end

  # Render the erb template.
  #
  # @param template_path [String]
  # @param locals [Hash]
  # @option options [Object] :scope (Object.new)
  #   Any object you want to bound to the template scope.
  # @option options [String, nil] :base_path (nil)
  #   The path of the directory for which the templates are going to be
  #   searched on.
  #
  # @note
  #   options also accepts any options offered by the Erubis templating system.
  #
  # @return [String]
  # @api public
  def self.render(template_path, locals = {}, options = {})
    scope = options.fetch(:scope) { Object.new }
    context = TemplateContext.new(scope, options)
    _render(template_path, locals, context, options)
  end

  # Render the erb template with the given context.
  #
  # @param template_path [String]
  # @param context [Armadillo::TemplateContext]
  # @param locals [Hash]
  # @option options [String] :base_path (nil)
  #
  # @note
  #   options also accepts any options offered by the Erubis templating system.
  #
  # @api private
  def self._render(template_path, locals, context, options)
    context.create_frame
    template_path = "#{template_path}.erb"
    if (base_path = options.fetch(:base_path, nil))
      template_path = File.join(base_path, template_path)
    end
    template = _templates_cache.fetch(template_path) do
      Tilt::ErubisTemplate.new(template_path, 1, DEFAULT_OPTIONS.merge(options))
    end

    content = template.render(context, locals)

    if context.extends?
      template_path, locals = context.extract_extends_data
      content = _render(template_path, locals, context, options)
    end

    content
  end
  private_class_method :_render

  # Get Tilt templates cache.
  #
  # @return [Tilt::Cache]
  #
  # @api private
  def self._templates_cache
    Thread.current[:tilt_cache] ||= Tilt::Cache.new
  end
  private_class_method :_templates_cache

end
