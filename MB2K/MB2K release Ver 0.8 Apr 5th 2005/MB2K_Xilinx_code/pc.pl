#ver 1.02
#added .mem file capability.
#
#ver 1.03
#added .coe file capability.
#added Ken Chapmans TEXT2HEX .hex file capability
#
####*****************************************************************************************
####**
####**  Disclaimer: LIMITED WARRANTY AND DISCLAMER. These designs are 
####**              provided to you "as is". Xilinx and its licensors make and you 
####**              receive no warranties or conditions, express, implied, statutory 
####**              or otherwise, and Xilinx specifically disclaims any implied 
####**              warranties of merchantability, non-infringement, or fitness for a 
####**              particular purpose. Xilinx does not warrant that the functions 
####**              contained in these designs will meet your requirements, or that the
####**              operation of these designs will be uninterrupted or error free, or 
####**              that defects in the Designs will be corrected. Furthermore, Xilinx 
####**              does not warrant or make any representations regarding use or the 
####**              results of the use of the designs in terms of correctness, accuracy, 
####**              reliability, or otherwise. 
####**
####**              LIMITATION OF LIABILITY. In no event will Xilinx or its licensors be 
####**              liable for any loss of data, lost profits, cost or procurement of 
####**              substitute goods or services, or for any special, incidental, 
####**              consequential, or indirect damages arising from the use or operation 
####**              of the designs or accompanying documentation, however caused and on 
####**              any theory of liability. This limitation will apply even if Xilinx 
####**              has been advised of the possibility of such damage. This limitation 
####**              shall apply not-withstanding the failure of the essential purpose of 
####**              any limited remedies herein. 
####**
####*****************************************************************************************
#
#
#
#
print "\n\n\n\n\n\n\n\n____________________________________________________\n";
print "*\n";
print "*	Preliminary script v1.03\n";
print "*	Author: Stephan Neuhold\n";
print "*\n";
print "____________________________________________________\n\n";
#
#
#
#
############################################################################
#Default commandline switch settings
############################################################################
use Getopt::Long;

GetOptions(	"-uf=s"		=>	\$user_file,
			"-pf=s"		=>	\$prom_file,
			"-ps=s"		=>	\$prom_size,
			"-swap=s"	=>	\$do_swap,
			"-sw=s"		=>	\$sync_word,
			"-fill=s"	=>	\$fill);
				
@prom_file_format = split(/\./, $prom_file);
if (lc@prom_file_format[1] eq "mcs")
{
	$format = "MCS";
	$do_swap = "Not available for MCS formats";
}
if (lc@prom_file_format[1] eq "hex")
{
	$format = "HEX";
	if ($do_swap eq "")
	{
		print "\n\nYou must specify the -swap option when using HEX PROM files\n\n";
		usage();
	}
}
if (lc@prom_file_format[1] eq "")
{
	print "\n\nUndefined PROM file format. Please specify the filename and the extensions\n\n";
	usage();
}
if ($prom_size eq "")
{
	print "\n\nYou must specify a PROM size using the -ps option\n\n";
	usage();
}
if ($user_file eq "")
{
	print "\n\nYou must specify a user data file with the -uf option\n\n";
	usage();
}
if ($fill eq "")
{
	$fill = "F";
}
else
{
	$fill = $fill;
}

sub usage
{
	print "usage:\n
		pc.pl [-f : PROM file format {mcs|hex}] [-swap : bits should be swapped {on|off}] [-ps PROM size {0.5|1|2|4|8|16|32}][-uf : user data file {<filename.ext>}] [-pf : PROM file {filename.ext}]\n
		-f = PROM file format used
			mcs => Intel file format
			hex => Simple hex file format\n
		
		-swap = Specify if bits are to be swapped
			on => swaps bits in every byte
			off => bits are not swapped\n
			
		-ps = Specify the PROM size used
			0.5 => 512Kbits
			1 => 1 Mbits
			2 => 2 Mbits
			4 => 4 Mbits
			5 => 8 Mbits
			16 => 16 Mbits
			32 => 32 Mbits\n
		
		-uf = File containing user data to be added to PROM file\n
		
		-pf = PROM file to which user data is to be added\n\n";
		exit;
}
#
#
#
#
############################################################################
#Detect whether user data is a mem or hex or txt or coe file
############################################################################
@memfilecheck = split(/\./, $user_file);
if (lc@memfilecheck[1] eq "mem" || lc@memfilecheck[1] eq "hex" || lc@memfilecheck[1] eq "txt")
{
	print "Formatting ", uc@memfilecheck[1]," file...\n";
	open (MEMFILE, $user_file) || die "Cannot open MEM file $user_file: $!";
	open (USERDATA, ">@memfilecheck[0]\.tmp@memfilecheck[1]") || die "Cannot create file @memfilecheck[0].tmp@memfilecheck[1]: $!";
	while (<MEMFILE>)
	{
		if ($_ =~ /^\/\//)
		{
			print "Ignoring comments...		\r";
		}
		elsif ($_ =~ /^@/)
		{
			print "Ignoring address...		\r";
		}
		else
		{
			$new_mem_line = $_;
			$new_mem_line =~ s/^\s+//;
			$new_mem_line =~ s/\s+$//;
			@split_mem_lines = split (/ /, $new_mem_line);
		}
		foreach $line(@split_mem_lines)
		{
			$one_line = $one_line.$line;
		}
	}
	$one_line = $sync_word.$one_line;
	@new_mem_array = split(//, $one_line);
	$array_size = ($#new_mem_array + 1) / 32;
	@trailers = split (/\./, $array_size);
	$rest = $array_size - @trailers[0];
	$nibbles_to_add = 32 - ($rest * 32);
	$last_nibble_in_array = $#new_mem_array;
	for ($s = 0; $s <= $nibbles_to_add; $s++)
	{
		@new_mem_array[$last_nibble_in_array + $s] = $fill;
	}
	$blurb_count = 0;
	for ($z = 0; $z < $#new_mem_array; $z = $z + 32)
	{
		for ($i = 0; $i < 32; $i++)
		{
			$blurb_count = $blurb_count + 1;
			print USERDATA $new_mem_array[$z + $i];
			print "Writing new format to @memfilecheck[0].tmp@memfilecheck[1]...$blurb_count		\r";
		}
		print USERDATA "\n";
	}
	print "\n____________________________________________________\n\n";
	close (MEMFILE) || die "Cannot close file $user_file: $!";
	close (USERDATA) || die "Cannot close file @memfilecheck[0]\.tmp@memfilecheck[1]: $!";
	$user_file = "@memfilecheck[0].tmp@memfilecheck[1]";
}
elsif (lc@memfilecheck[1] eq "coe")
{
	print "Formatting ", uc@memfilecheck[1], " file...\n";
	open (COEFILE, $user_file) || die "Cannot open COE file $user_file: $!";
	open (USERDATA, ">@memfilecheck[0]\.tmp@memfilecheck[1]") || die "Cannot create file @memfilecheck[0].tmp@memfilecheck[1]: $!";
	while (<COEFILE>)
	{
		chomp;
		if (/memory_initialization_vector/ .. /;/)
		{
			@coeffs = (@coeffs, $_);
		}
	}
	for ($i = 1; $i <= $#coeffs - 1; $i++)
	{
		@coeffs[$i - 1] = @coeffs[$i];
	}
	foreach $coeff_line(@coeffs)
	{
		chomp($coeff_line);
		@coeff_line_split = split(/,/, $coeff_line);
		foreach $coeff(@coeff_line_split)
		{
			$coefficient = $coeff;
			$coefficient =~ s/^\s+//;
			$coefficient =~ s/\s+$//;
			$coefficient =~ s/;//;
			$coefficients = $coefficients.$coefficient;
		}
	}
	$coefficients = $sync_word.$coefficients;
	@new_coe_array = split(//, $coefficients);
	$array_size = ($#new_coe_array + 1) / 32;
	@trailers = split (/\./, $array_size);
	$rest = $array_size - @trailers[0];
	$nibbles_to_add = 32 - ($rest * 32);
	$last_nibble_in_array = $#new_coe_array;
	for ($s = 0; $s <= $nibbles_to_add; $s++)
	{
		@new_coe_array[$last_nibble_in_array + $s] = "F";
	}
	$blurb_count = 0;
	for ($z = 0; $z < $#new_coe_array; $z = $z + 32)
	{
		for ($i = 0; $i < 32; $i++)
		{
			$blurb_count = $blurb_count + 1;
			print USERDATA $new_coe_array[$z + $i];
			print "Writing new format to @memfilecheck[0].tmp@memfilecheck[1]...$blurb_count		\r";
		}
		print USERDATA "\n";
	}
	print "\n____________________________________________________\n\n";
	close (COEFILE) || die "Cannot close file $user_file: $!";
	close (USERDATA) || die "Cannot close file @memfilecheck[0]\.tmp@memfilecheck[1]: $!";
	$user_file = "@memfilecheck[0].tmp@memfilecheck[1]";
}
#
#
#
#
############################################################################
#Initialise all variables
############################################################################
$prom_line_number = 0;
$user_line_number = 0;
#
#
#
#
############################################################################
#Print settings used
############################################################################
print "\n\n";
print "Running script with following settings:\n";
print "	PROM file format	==>	$format\n";
print "	Bit swapping		==>	$do_swap\n";
print "	User data file		==>	$user_file\n";
print "	Original PROM file	==>	$prom_file\n\n\n";
print "New PROM file is		==>	new_$prom_file\n\n";
print "____________________________________________________\n\n";
#
#
#
#
############################################################################
#Open files and begin processing
############################################################################
open (USER_DATA, "<$user_file") || die "Cannot open file $user_file: $!";
open (NEW_PROM_FILE, ">new_$prom_file") || die "Cannot open file new_$prom_file: $!";
open (PROM_FILE, "<$prom_file") || die "Cannot open file $prom_file: $!";
while (<PROM_FILE>)
{
	$current_prom_line = $_;
	if (lc@prom_file_format[1] eq "mcs")
	{
		print "Copying original PROM line number $prom_line_number...		\r";
		$prom_line_number = $prom_line_number + 1;
		get_current_mcs_prom_line_data();
		
		if ($current_prom_line =~ /^\:00000001FF/)
		{
			print "\n";
			$new_address_offset = 0;
			while (<USER_DATA>)
			{
				chomp;
				if ($_ =~ /^\#/)
				{
					print "Ignoring comment\r";
				}
				elsif ($_ =~ /\#/g)
				{
					@split_user_line = split(/\#/, $_);
					$current_user_line = @split_user_line[0];
					print "Processing USER line $user_line_number...		\r";
					$user_line_number = $user_line_number + 1;
					get_mcs_address();
				}
				else
				{
					$current_user_line = $_;
					print "Processing USER line $user_line_number...		\r";
					$user_line_number = $user_line_number + 1;
					get_mcs_address();
				}
			}
			print NEW_PROM_FILE $current_prom_line;
		}
		else
		{
			print NEW_PROM_FILE $current_prom_line;
			$previous_prom_line = $current_prom_line;
		}
	}
	elsif (lc@prom_file_format[1] eq "hex")
	{
	    if (lc$do_swap eq "on")
	    {
    		$current_prom_line = $_;
	    	print "Copying original PROM line number $prom_line_number...\r";
			$prom_line_number = $prom_line_number + 1;
	    	print NEW_PROM_FILE $current_prom_line;
	    	hex_prom_file_byte_count();
	    	print "\n";
    		while (<USER_DATA>)
    		{
	    		if ($_ =~ /^\#/)
	    		{
		    		print "Ignoring comment\r";
	    		}
	    		elsif ($_ =~ /\#/g)
	    		{
		    		chomp;
		    		@split_user_line = split(/\#/, $_);
		    		$current_user_line = @split_user_line[0];
	    			print "Processing USER line $user_line_number...			\r";
					$user_line_number = $user_line_number + 1;
    				(@bytes_hex) = unpack("A2 A2 A2 A2 A2 A2 A2 A2 A2 A2 A2 A2 A2 A2 A2 A2", $current_user_line);
    				foreach $byte_hex(@bytes_hex)
    				{
    					$byte_dec = hex($byte_hex);
    					$byte_binary = decimal2binary($byte_dec);
    					$last_eight_bits = substr($byte_binary, -8);
    					(@last_eight_bits_not_swapped) = unpack("A1 A1 A1 A1 A1 A1 A1 A1", $last_eight_bits);
    					@last_eight_bits_swapped = reverse(@last_eight_bits_not_swapped);
    					$byte_swapped_bin = 0;
    					foreach $bit(@last_eight_bits_swapped)
    					{
		    				$byte_swapped_bin = $byte_swapped_bin.$bit;
    					}
    					$byte_swapped_dec = binary2decimal($byte_swapped_bin);
    					$byte_swapped_hex = sprintf "%lx", $byte_swapped_dec;
    					$byte_hex = substr($byte_swapped_hex, -2);
    					if ($byte_swapped_dec <= 15)
    					{
		    				$byte_hex = "0$byte_hex";
    					}
    					print NEW_PROM_FILE uc("$byte_hex");
    				}
				}
				else
				{
					chomp;
					$current_user_line = $_;
					print "Processing USER line $user_line_number...			\r";
					$user_line_number = $user_line_number + 1;
    				(@bytes_hex) = unpack("A2 A2 A2 A2 A2 A2 A2 A2 A2 A2 A2 A2 A2 A2 A2 A2", $current_user_line);
    				foreach $byte_hex(@bytes_hex)
    				{
    					$byte_dec = hex($byte_hex);
    					$byte_binary = decimal2binary($byte_dec);
    					$last_eight_bits = substr($byte_binary, -8);
    					(@last_eight_bits_not_swapped) = unpack("A1 A1 A1 A1 A1 A1 A1 A1", $last_eight_bits);
    					@last_eight_bits_swapped = reverse(@last_eight_bits_not_swapped);
    					$byte_swapped_bin = 0;
    					foreach $bit(@last_eight_bits_swapped)
    					{
		    				$byte_swapped_bin = $byte_swapped_bin.$bit;
    					}
    					$byte_swapped_dec = binary2decimal($byte_swapped_bin);
    					$byte_swapped_hex = sprintf "%lx", $byte_swapped_dec;
    					$byte_hex = substr($byte_swapped_hex, -2);
    					if ($byte_swapped_dec <= 15)
    					{
		    				$byte_hex = "0$byte_hex";
    					}
    					print NEW_PROM_FILE uc("$byte_hex");
    				}
				}
    		}
    	}
    	elsif (lc$do_swap eq "off")
    	{
    		$current_prom_line = $_;
	    	print "Copying original PROM line number $prom_line_number...\r";
			$prom_line_number = $prom_line_number + 1;
	    	print NEW_PROM_FILE $current_prom_line;
	    	hex_prom_file_byte_count();
	    	print "\n";
    		while (<USER_DATA>)
    		{
	    		if ($_ =~ /^\#/)
	    		{
		    		print "Ignoring comment\r";
	    		}
	    		elsif ($_ =~ /\#/g)
	    		{
		    		chomp;
		    		@split_user_line = split(/\#/, $_);
		    		$current_user_line = @split_user_line[0];
	    			print "Processing USER line $user_line_number...			\r";
					$user_line_number = $user_line_number + 1;
    				print NEW_PROM_FILE uc("$current_user_line");
				}
				else
				{
					chomp;
					print "Processing USER line $user_line_number...			\r";
					$user_line_number = $user_line_number + 1;
    				$current_user_line = $_;
    				print NEW_PROM_FILE uc("$current_user_line");
				}
    		}
    	}
	}
}
print "\n____________________________________________________\n\n\n";
$total_user_byte_count = $user_line_number * 8;
$prom_size = ($prom_size * 1024 * 1024) / 8;
$bytes_left = $prom_size - $total_user_byte_count - $total_byte_count;
print "\n\nUSER BYTE COUNT   = $total_user_byte_count bytes\n";
print "PROM BYTE COUNT   = $total_byte_count bytes\n";
print "PROM SIZE         = $prom_size bytes\n";
print "____________________________________________________\n";
print "BYTES LEFT        = $bytes_left bytes\n";
if ($bytes_left < 0)
{
	print "\nPROM data is too large to fit in PROM\n";
}
close (USER_DATA) || die "Cannot close file $user_file: $!";
close (PROM_FILE) || die "Cannot close file $prom_file: $!";
close (NEW_PROM_FILE) || die "Cannot close file new_$prom_file: $!";
unlink <*.tmp@memfilecheck[1]>;
print "\nDONE...\n\n\n\n\n\n";
#
#
#
#
############################################################################
#Get the data from the current prom line
############################################################################
sub get_current_mcs_prom_line_data
{
	($start_character, $byte_count_hex) = unpack("A1 A2", $current_prom_line);
	$byte_count_dec = hex($byte_count_hex);
	($record_type) = unpack("x7 A2", $current_prom_line);
	if ($record_type eq "00")
	{
		$total_byte_count = $total_byte_count + $byte_count_dec;
	}
	$byte_count_dec = $byte_count_dec * 2;	
	(	$start_character,
		$byte_count_hex,
		$address_hex[0],
		$address_hex[1],
		$record_type_hex,
		$all_data_hex,
		$checksum_hex
	) = unpack("A1 A2 A2 A2 A2 A$byte_count_dec A2", $current_prom_line);
	if ($record_type eq "04")
	{
		$last_04_record_data_hex = $all_data_hex;
	}
}
#
#
#
#
############################################################################
#Calculate the new address to be used
############################################################################
sub get_mcs_address
{
	($address_hex) = unpack("x3 A4", $previous_prom_line);
	$address_dec = hex($address_hex);
	if ($address_dec eq "65520")
	{
		$temporary_current_user_line = $current_user_line;
		$new_address_dec = 0;
		$new_address_hex = "0000";
		($address_hex[0], $address_hex[1]) = unpack("A2 A2", $new_address_hex);
	    $address_dec[0] = hex($address_hex[0]);
    	$address_dec[1] = hex($address_hex[1]);
		$new_address_offset = 0;
		$new_04_record_data_dec = hex($last_04_record_data_hex);
		$new_04_record_data_dec = $new_04_record_data_dec + 1;
		$new_04_record_data_hex = sprintf "%lx", $new_04_record_data_dec;
		$last_04_record_data_hex = $new_04_record_data_hex;
		$length = length($new_04_record_data_hex);
		if ($length > 4)
		{
			die "Record data is too large....Quitting: $!";
		}
		else
		{
			for ($i = 0; $i < 4 - $length; $i++)
			{
				$new_04_record_data_hex = "0$new_04_record_data_hex";
			}
		}
		$byte_count_hex = "02";
		$byte_count_dec = hex($byte_count_hex);
		$record_type_hex = "04";
		$record_type_dec = hex($record_type_hex);
		$current_user_line = $new_04_record_data_hex;
		calculate_mcs_checksum();
		print NEW_PROM_FILE uc(":$byte_count_hex$new_address_hex$record_type_hex$new_04_record_data_hex$checksum_hex\n");
		$previous_prom_line = uc(":$byte_count_hex$new_address_hex$record_type_hex$new_04_record_data_hex$checksum_hex\n");
		$current_user_line = $temporary_current_user_line;
	}
	else
	{
		$new_address_offset = 16;
		$new_address_dec = $address_dec + $new_address_offset;
	}
	$new_address_hex = sprintf "%lx", $new_address_dec;
	$length = length($new_address_hex);
	if ($length > 4)
	{
		die "Address is too large....Quitting: $!";
	}
	else
	{
		for ($i = 0; $i < 4 - $length; $i++)
		{
			$new_address_hex = "0$new_address_hex";
		}
	}
	($address_hex[0], $address_hex[1]) = unpack("A2 A2", $new_address_hex);
    $address_dec[0] = hex($address_hex[0]);
    $address_dec[1] = hex($address_hex[1]);
	$byte_count_dec = "16";
	$byte_count_hex = "10";
	$record_type_dec = "00";
	$record_type_hex = "00";
	calculate_mcs_checksum();
	print NEW_PROM_FILE uc(":$byte_count_hex$new_address_hex$record_type_hex$current_user_line$checksum_hex\n");
	$previous_prom_line = uc(":$byte_count_hex$new_address_hex$record_type_hex$current_user_line$checksum_hex\n");
}
#
#
#
#
############################################################################
#Calculate the checksum for the new line
############################################################################
sub calculate_mcs_checksum
{
	$skip = 0;
	$data_sum_hex = 0;
	$data_sum_dec = 0;
	for ($d = 0; $d < $byte_count_dec; $d++)
	{
		($data_hex[$d]) = unpack("x$skip A2", $current_user_line);
		$skip = $skip + 2;
		$data_dec[$d] = hex($data_hex[$d]);
		$data_sum_dec = $data_sum_dec + $data_dec[$d];
		$data_sum_hex = sprintf "%lx", $data_sum_dec;
	}
	$all_sum_dec = $data_sum_dec + $byte_count_dec + $address_dec[0] + $address_dec[1] + $record_type_dec;
    $all_sum_hex = sprintf "%lx", $all_sum_dec;
    $last_two_bytes_of_sum_hex = substr($all_sum_hex, -2);
    $last_two_bytes_of_sum_dec = hex($last_two_bytes_of_sum_hex);
    $inverted_dec = $last_two_bytes_of_sum_dec ^ 255;
    $inverted_hex = sprintf "%lx", $inverted_dec;
    $last_two_bytes_of_inverted_dec = hex($inverted_hex);
    $checksum_dec = $last_two_bytes_of_inverted_dec + 1;
    $last_two_bytes_2s_hex = uc(sprintf "%lx", $checksum_dec);
    ($checksum_he) = substr($last_two_bytes_2s_hex, -2);
    if ($checksum_dec <= 15)
    {
    	$checksum_hex = "0$checksum_he";
    }
    else
    {
    	$checksum_hex = $checksum_he;
    }
}
#
#
#
#
############################################################################
#Get HEX file byte count
############################################################################
sub hex_prom_file_byte_count
{
	@hex_prom_size = split(//, $current_prom_line);
	$total_byte_count = ($#hex_prom_size + 1) / 2;
}
#
#
#
#
############################################################################
#Decimal to binary representation conversion
############################################################################
sub decimal2binary
{
    my $bin_value = unpack("B32", pack("N", shift));
    $bin_value =~ s/^0+(?=d)//;
    return $bin_value;
}
#
#
#
#
############################################################################
#Binary to decimal representation conversion
############################################################################
sub binary2decimal
{
    return unpack("N", pack("B32", substr("0" x 32 . shift, -32)));
}