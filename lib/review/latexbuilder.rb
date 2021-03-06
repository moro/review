#
#
# Copyright (c) 2002-2007 Minero Aoki
#               2008-2009 Minero Aoki, Kenshi Muto
#               2010  Minero Aoki, Kenshi Muto, TAKAHASHI Masayoshi
#
# This program is free software.
# You can distribute or modify this program under the terms of
# the GNU LGPL, Lesser General Public License version 2.1.
# For details of the GNU LGPL, see the file "COPYING".
#

require 'review/builder'
require 'review/latexutils'
require 'review/textutils'

module ReVIEW

  class LATEXBuilder < Builder

    include LaTeXUtils
    include TextUtils

    Compiler.defblock(:memo, 0..1)

    def extname
      '.tex'
    end

    def builder_init_file
      #@index = indexes[:latex_index]
      @blank_needed = false
    end
    private :builder_init_file

    def blank
      @blank_needed = true
    end
    private :blank

    def print(*s)
      if @blank_needed
        @output.puts
        @blank_needed = false
      end
      super
    end
    private :print

    def puts(*s)
      if @blank_needed
        @output.puts
        @blank_needed = false
      end
      super
    end
    private :puts

    HEADLINE = {
      1 => 'chapter',
      2 => 'section',
      3 => 'subsection',
      4 => 'subsubsection',
      5 => 'paragraph'
    }

    def headline(level, label, caption)
      prefix = ""
      if level > @param["secnolevel"]
        prefix = "*"
      end
      blank unless @output.pos == 0
      puts macro(HEADLINE[level]+prefix, escape(caption))
    end

    def column_begin(level, label, caption)
      blank
      puts "\\begin{reviewcolumn}\n\\reviewcolumnhead{#{label}}{#{escape(caption)}}"
=begin
      ## puts '\vspace{2zw}' 
      puts '\begin{center}'
      puts '\begin{minipage}{0.9\linewidth}'
      puts '\begin{framed}'
      puts '\setlength{\FrameSep}{2zw}'

      headline(2, label, caption)   # FIXME
=end

    end

    def column_end(level)
      puts "\\end{reviewcolumn}"
=begin
      puts '\end{framed}'
      puts '\end{minipage}'
      puts '\end{center}'
      ## puts '\vspace{2zw}'
=end
      blank
    end

    def minicolumn(type, lines, caption)
      puts "\\begin{reviewminicolumn}\n"
      unless caption.nil?
        puts "\\reviewminicolumntitle{#{escape(caption)}}\n"
      end
      lines.each {|l|
        puts l
      }
      puts "\\end{reviewminicolumn}\n"
    end

    def memo(lines, caption = nil)
      minicolumn("memo", lines, caption)
    end

    def ul_begin
      blank
      puts '\begin{itemize}'
    end

    def ul_item(lines)
      puts '\item ' + lines.join("\n")
    end

    def ul_end
      puts '\end{itemize}'
      blank
    end

    def ol_begin
      blank
      puts '\begin{enumerate}'
    end

    def ol_item(lines, num)
      puts '\item ' + lines.join("\n")
    end

    def ol_end
      puts '\end{enumerate}'
      blank
    end

    def dl_begin
      blank
      puts '\begin{description}'
    end

    def dt(str)
      puts '\item[' + str + '] \mbox{} \\\\'
    end

    def dd(lines)
      lines.each do |line|
        puts line
      end
    end

    def dl_end
      puts '\end{description}'
      blank
    end

    def paragraph(lines)
      blank
      lines.each do |line|
        puts line
      end
      blank
    end

    def parasep()
      puts '\\parasep'
    end

    def read(lines)
      latex_block 'quotation', lines
    end

    alias lead read

    def emlist(lines)
      blank
      puts '\begin{reviewemlist}'
      puts '\begin{verbatim}'
      lines.each do |line|
        puts line
      end
      puts '\end{verbatim}'
      puts '\end{reviewemlist}'
      blank
    end

    def cmd(lines)
      blank
      puts '\begin{reviewcmd}'
      puts '\begin{verbatim}'
      lines.each do |line|
        puts line
      end
      puts '\end{verbatim}'
      puts '\end{reviewcmd}'
      blank
    end

    def list_header(id, caption)
      puts macro('reviewlistcaption', "#{@chapter.number}.#{@chapter.list(id).number}", text(caption))
    end

    def list_body(lines)
      puts '\begin{reviewlist}'
      puts '\begin{verbatim}'
      lines.each do |line|
        puts line
      end
      puts '\end{verbatim}'
      puts '\end{reviewlist}'
      puts
    end

    def image_header(id, caption)
    end

    def image_image(id, metric, caption)
      # image is always bound here
      puts '\begin{reviewimage}'
      if metric
        puts "\\includegraphics[#{metric}]{#{@chapter.image(id).path}}"
      else
        puts macro('includegraphics', @chapter.image(id).path)
      end
      puts macro('label', image_label(id))
      if !caption.empty?
        puts macro('caption', text(caption))
      end
      puts '\end{reviewimage}'
    end

    def image_dummy(id, caption, lines)
      puts '\begin{reviewdummyimage}'
      puts '\begin{verbatim}'
      path = @chapter.image(id).path
      puts "--[[path = #{path} (#{existence(id)})]]--"
      lines.each do |line|
        puts detab(line.rstrip)
      end
      puts '\end{verbatim}'
      puts macro('label', image_label(id))
      puts text(caption)
      puts '\end{reviewdummyimage}'
    end

    def existence(id)
      @chapter.image(id).bound? ? 'exist' : 'not exist'
    end
    private :existence

    def image_label(id)
      "image:#{@chapter.id}:#{id}"
    end
    private :image_label

    def table_header(id, caption)
      puts macro('reviewtablecaption', "#{@chapter.number}.#{@chapter.table(id).number}", escape(caption))
    end

    def table_begin(ncols, preamble)
      if preamble
        puts macro('begin', 'reviewtable', preamble)
      else
        puts macro('begin', 'reviewtable', (['|'] * (ncols + 1)).join('l'))
      end
      puts '\hline'
    end

    def table_separator
      #puts '\hline'
    end

    def th(s)
      macro('textgt', s)
    end

    def td(s)
      s
    end

    def tr(rows)
      print rows.join(' & ')
      puts ' \\\\  \hline'
    end

    def table_end
      puts macro('end', 'reviewtable')
      blank
    end

    def quote(lines)
      latex_block 'quotation', lines
    end

    def center(lines)
      latex_block 'center', lines
    end

    def right(lines)
      latex_block 'flushright', lines
    end

    def latex_block(type, lines)
      blank
      puts macro('begin', type)
      lines.each do |line|
        puts line
      end
      puts macro('end', type)
      blank
    end
    private :latex_block

    def direct(lines, fmt)
      return unless fmt == 'latex'
      lines.each do |line|
        puts line
      end
    end

    def comment(str)
      puts "% #{str}"
    end

    def label(id)
      puts macro('label', id)
    end

    def pagebreak
      puts '\pagebreak'
    end

    def linebreak
      puts '\\\\'
    end

    def noindent
      puts '\noindent'
    end

    # FIXME: use TeX native label/ref.
    def inline_list(id)
      macro('reviewlistref', "#{@chapter.number}.#{@chapter.list(id).number}")
    end

    def inline_table(id)
      macro('reviewtableref', "#{@chapter.number}.#{@chapter.table(id).number}")
    end

    def inline_img(id)
      macro('reviewimageref', "#{@chapter.number}.#{@chapter.image(id).number}")
    end

    def footnote(id, content)
    end

    def inline_fn(id)
      macro('footnote', compile_inline(@chapter.footnote(id).content.strip))
    end

    BOUTEN = "・"

    def inline_bou(str)
      str.split(//).map {|c| macro('ruby', escape(c), macro('textgt', BOUTEN)) }.join('\allowbreak')
    end

    def inline_ruby(str)
      base, ruby = *str.split(/,/)
      macro('ruby', base, ruby)
    end

    # math
    def inline_m(str)
      " $#{str}$ "
    end

    # hidden index
    def inline_hi(str)
      index(str)
    end

    # index
    def inline_i(str)
      escape(str) + index(str)
    end

    # bold
    def inline_b(str)
      macro('textbf', escape(str))
    end

    def nofunc_text(str)
      escape(str)
    end

    def inline_tt(str)
      macro('texttt', escape(str))
    end

    def inline_raw(str)
      escape(str)
    end

    def index(str)
      str.sub!(/\(\)/, '')
      decl = ''
      if /@\z/ =~ str
        str.chop!
        decl = '|IndexDecl'
      end
      unless /[^ -~]/ =~ str
        if /\^/ =~ str
          macro('index', escape_index(str.gsub(/\^/, '')) + '@' + escape_index(text(str)) + decl)
        else
          '\index{' + escape_index(text(str)) + decl + '}'
        end
      else
        '\index{' + escape_index(@index_db[str]) + '@' + escape_index(text(str)) + '}'
      end
    end

    def compile_kw(word, alt)
      if alt
        macro('textgt', escape(word)) + "（#{escape(alt.strip)}）"
      else
        macro('textgt', escape(word))
      end
    end

    def compile_href(url, label)
      label ||=  url
      if /\A[a-z]+:\/\// =~ url
        macro("href", url, escape(label))
      else
        macro("ref", url)
      end
    end

    def tsize(str)
      # dummy
    end

  end

end
