require 'nokogiri'

target = ARGV[0]

def confirmStructure(target)
  warnings = []
  warnings << "#{target} is not a directory" unless File.directory?(target)
  warnings << "Missing metadata directory!" unless File.directory?("#{target}/metadata")
  @isobusterReports = Dir.glob("#{target}/**/isobuster-report.xml")
  warnings << "No Isobuster reports found!" unless @isobusterReports.length > 0
  if warnings.length > 0
    puts "Please recheck input! The following errors are present:"
    warnings.each {|warning| puts warning}
    exit
  end
end

def getIsoContents(report)
  reportXML =  Nokogiri::XML(File.read(report))
  fileXML = reportXML.search("filename")
  parsedReport = []
  assignedDiscName = File.basename(File.dirname(report))
  reportPath = File.dirname(File.dirname(report))
  isoDir = File.expand_path('../..',reportPath) + "/#{assignedDiscName}"
  originalDiscName =  File.basename(Dir.glob("#{isoDir}/*.iso")[0])
  parsedReport = []
  parsedReport << "Assigned disc name: #{assignedDiscName}"
  parsedReport << "Original disc name: #{originalDiscName}"
  fileXML.each {|file| parsedReport << file.inner_text}
  parsedReport << "-----"
  parsedReport << ""
  parsedReport
end

confirmStructure(target)
outputArray = []
@isobusterReports.sort.each {|report| outputArray << getIsoContents(report)}

File.open("#{target}/metadata/#{File.basename(target)}-file-manifest.txt", "w+") do |f|
  outputArray.each { |line| f.puts(line) }
end
