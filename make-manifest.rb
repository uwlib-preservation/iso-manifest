require 'nokogiri'

target = ARGV[0]

def confirmStructure(target)
  warnings = []
  warnings << "#{target} is not a directory" unless File.directory?(target)
  if File.directory?("#{target}/metadata")
    @outputDir = "#{target}/metadata"
  else
    @outputDir = "#{target}"
    puts "Missing metadata directory - manifest will be output into target directory."
  end
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
  puts assignedDiscName
  reportPath = File.dirname(File.dirname(report))
  isoDir = File.expand_path(reportPath) + "/#{assignedDiscName}"
  puts isoDir
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

File.open("#{@outputDir}/#{File.basename(target)}_manifest.txt", "w+") do |f|
  outputArray.each { |line| f.puts(line) }
end
