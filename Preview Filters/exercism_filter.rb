#!/usr/bin/env ruby

require 'redcarpet'

ARGF.set_encoding('UTF-8')

module Compatability
	private
	
	def hightlighting?
		require 'rouge'
		require 'rouge/plugins/redcarpet'
	rescue LoadError
		false
	end
end

class SyntaxHighlightRenderer < Redcarpet::Render::HTML 
	extend Compatability
	include Rouge::Plugins::Redcarpet if hightlighting?
	
	ICONS = {
		info: %q(<svg version="1.1" width="16" height="16" viewBox="0 0 16 16" class="icon" aria-hidden=""><path d="M0 8a8 8 0 1 1 16 0A8 8 0 0 1 0 8Zm8-6.5a6.5 6.5 0 1 0 0 13 6.5 6.5 0 0 0 0-13ZM6.5 7.75A.75.75 0 0 1 7.25 7h1a.75.75 0 0 1 .75.75v2.75h.25a.75.75 0 0 1 0 1.5h-2a.75.75 0 0 1 0-1.5h.25v-2h-.25a.75.75 0 0 1-.75-.75ZM8 6a1 1 0 1 1 0-2 1 1 0 0 1 0 2Z"></path></svg>),
		caution: %q(<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 16 16" class="icon"><path d="M6.457 1.047c.659-1.234 2.427-1.234 3.086 0l6.082 11.378A1.75 1.75 0 0 1 14.082 15H1.918a1.75 1.75 0 0 1-1.543-2.575Zm1.763.707a.25.25 0 0 0-.44 0L1.698 13.132a.25.25 0 0 0 .22.368h12.164a.25.25 0 0 0 .22-.368Zm.53 3.996v2.5a.75.75 0 0 1-1.5 0v-2.5a.75.75 0 0 1 1.5 0ZM9 11a1 1 0 1 1-2 0 1 1 0 0 1 2 0Z"/></svg>),
	}
	
	RENDER_OPTIONS = {
		:autolink => true,
		:space_after_headers => true,
		:fenced_code_blocks => true,
		:disable_indented_code_blocks => true,
		:no_intra_emphasis => true,
		:lax_html_blocks => true,
		:lax_spacing => true,
		:strikethrough => true,
		:tables => true
	}
	
	def initialize(extensions = {})
			super extensions.merge(link_attributes: { target: '_blank' })
	end
	
	def preprocess(markdown_doc)
		nested_md = Redcarpet::Markdown.new(self, RENDER_OPTIONS)
		markdown_doc.gsub!( %r[^~{4}exercism/(note|caution|advanced)\n([\s\S]*?)~{4}$] ) do
			type    = $~[1]
			content = nested_md.render($~[2].chomp)
			icon    = /note|advanced/ === type ? :info : :caution
			%Q(<div class="info-box #{type}"><div class="titlebar"><p class="title">#{ICONS[icon]}#{type.capitalize}</p></div><div class="body">#{content}</div></div>)
		end
		markdown_doc
	end
end

md_to_html = Redcarpet::Markdown.new(SyntaxHighlightRenderer, SyntaxHighlightRenderer::RENDER_OPTIONS)
input_markdown = ARGF.read
puts md_to_html.render(input_markdown)
