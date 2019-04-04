senders = {} of String => Int32

File.each_line("exim_mainlog") { |line|
  if line =~ /^(?:\S+ ){3,4}<= ([^@]+@(\S+))/
    if senders.has_key? $~[1]
      senders[$~[1]] += 1
    else
      senders[$~[1]] = 1
    end
  end
}

emails = senders.keys
emails.sort! { |a,b| senders[b] <=> senders[a] }
emails.first(5).each{ |k|
  puts "#{senders[k]} #{k}"
}
