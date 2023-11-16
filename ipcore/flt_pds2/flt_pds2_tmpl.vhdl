-- Created by IP Generator (Version 2022.2 build 117120)
-- Instantiation Template
--
-- Insert the following codes into your VHDL file.
--   * Change the_instance_name to your own instance name.
--   * Change the net names in the port map.


COMPONENT flt_pds2
  PORT (
    i_aclk : IN STD_LOGIC;
    i_axi4s_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    i_axi4s_a_tvalid : IN STD_LOGIC;
    o_axi4s_result_tdata : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    o_axi4s_result_tvalid : OUT STD_LOGIC
  );
END COMPONENT;


the_instance_name : flt_pds2
  PORT MAP (
    i_aclk => i_aclk,
    i_axi4s_a_tdata => i_axi4s_a_tdata,
    i_axi4s_a_tvalid => i_axi4s_a_tvalid,
    o_axi4s_result_tdata => o_axi4s_result_tdata,
    o_axi4s_result_tvalid => o_axi4s_result_tvalid
  );
