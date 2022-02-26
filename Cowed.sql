-- phpMyAdmin SQL Dump
-- version 2.11.3deb1ubuntu1.3
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Aug 30, 2010 at 10:13 PM
-- Server version: 5.0.51
-- PHP Version: 5.2.4-2ubuntu5.10

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

--
-- Database: `cowed_game`
--

-- --------------------------------------------------------

--
-- Table structure for table `c_admins`
--

CREATE TABLE IF NOT EXISTS `c_admins` (
  `ckey` varchar(30) NOT NULL,
  `rank` int(11) NOT NULL default '1',
  PRIMARY KEY  (`ckey`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `c_admin_log`
--

CREATE TABLE IF NOT EXISTS `c_admin_log` (
  `id` int(11) NOT NULL auto_increment,
  `admin` varchar(30) NOT NULL,
  `body` text NOT NULL,
  `date` bigint(20) NOT NULL,
  `time` bigint(20) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `admin` (`admin`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=451 ;

-- --------------------------------------------------------

--
-- Table structure for table `c_bans`
--

CREATE TABLE IF NOT EXISTS `c_bans` (
  `key` varchar(30) NOT NULL,
  `id` varchar(30) NOT NULL,
  `admin` varchar(30) NOT NULL,
  `reason` varchar(255) NOT NULL,
  KEY `key` (`key`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `c_books`
--

CREATE TABLE IF NOT EXISTS `c_books` (
  `title` varchar(255) NOT NULL,
  `author` varchar(30) NOT NULL,
  `updated` int(11) NOT NULL,
  `approved` enum('1','0') NOT NULL default '0',
  PRIMARY KEY  (`title`),
  KEY `author` (`author`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `c_books_int`
--

CREATE TABLE IF NOT EXISTS `c_books_int` (
  `book` varchar(255) NOT NULL,
  `title` varchar(255) NOT NULL,
  `body` text NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `c_chat_log`
--

CREATE TABLE IF NOT EXISTS `c_chat_log` (
  `id` int(11) NOT NULL auto_increment,
  `key` varchar(30) NOT NULL,
  `name` varchar(30) NOT NULL,
  `message` text NOT NULL,
  `m_type` enum('event','say','emote','ooc','gmsay','adminhelp') NOT NULL,
  `date` bigint(20) NOT NULL,
  `time` bigint(20) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `key` (`key`,`m_type`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=5700 ;

-- --------------------------------------------------------

--
-- Table structure for table `c_key_cache`
--

CREATE TABLE IF NOT EXISTS `c_key_cache` (
  `ckey` varchar(30) NOT NULL,
  `key` varchar(30) NOT NULL,
  PRIMARY KEY  (`ckey`),
  UNIQUE KEY `key` (`key`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `c_medals`
--

CREATE TABLE IF NOT EXISTS `c_medals` (
  `ckey` varchar(30) NOT NULL,
  `medal` varchar(255) NOT NULL,
  `sync` enum('Y','N','D') NOT NULL default 'N'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `c_players`
--

CREATE TABLE IF NOT EXISTS `c_players` (
  `ckey` varchar(30) NOT NULL,
  `key` varchar(30) NOT NULL,
  `activity` int(11) NOT NULL,
  `gender` enum('male','female') NOT NULL default 'male',
  `name` varchar(30) NOT NULL,
  `music` int(11) NOT NULL default '75',
  `sound` int(11) NOT NULL default '100',
  `score_deaths` int(11) NOT NULL default '0',
  `score_royalblood` int(11) NOT NULL default '0',
  `score_taxes` int(11) NOT NULL default '0',
  `score_rppoints` int(11) NOT NULL default '0',
  `medal_woodcutter` int(11) NOT NULL default '0',
  `medal_chef` int(11) NOT NULL default '0',
  `medal_painter` int(11) NOT NULL default '0',
  `medal_saint` int(11) NOT NULL default '0',
  PRIMARY KEY  (`ckey`),
  UNIQUE KEY `key` (`key`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `c_player_associates`
--

CREATE TABLE IF NOT EXISTS `c_player_associates` (
  `id` varchar(16) NOT NULL,
  `id_type` enum('ip','id') NOT NULL,
  `ckey` varchar(30) NOT NULL,
  KEY `id` (`id`,`ckey`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `c_player_names`
--

CREATE TABLE IF NOT EXISTS `c_player_names` (
  `id` int(11) NOT NULL auto_increment,
  `ckey` varchar(30) NOT NULL,
  `name` varchar(30) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=432 ;
