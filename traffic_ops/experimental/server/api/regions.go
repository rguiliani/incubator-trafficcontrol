// Copyright 2015 Comcast Cable Communications Management, LLC

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// This file was initially generated by gen_to_start.go (add link), as a start
// of the Traffic Ops golang data model

package api

import (
	"encoding/json"
	_ "github.com/Comcast/traffic_control/traffic_ops/experimental/server/output_format" // needed for swagger
	"github.com/jmoiron/sqlx"
	"log"
	"time"
)

type Regions struct {
	Name      string       `db:"name" json:"name"`
	Division  string       `db:"division" json:"division"`
	CreatedAt time.Time    `db:"created_at" json:"createdAt"`
	Links     RegionsLinks `json:"_links" db:-`
}

type RegionsLinks struct {
	Self string `db:"self" json:"_self"`
}

// @Title getRegionsById
// @Description retrieves the regions information for a certain id
// @Accept  application/json
// @Param   id              path    int     false        "The row id"
// @Success 200 {array}    Regions
// @Resource /api/2.0
// @Router /api/2.0/regions/{id} [get]
func getRegionsById(name string, db *sqlx.DB) (interface{}, error) {
	ret := []Regions{}
	arg := Regions{}
	arg.Name = name
	queryStr := "select *, concat('" + API_PATH + "regions/', name) as self"
	queryStr += " from regions WHERE name=:name"
	nstmt, err := db.PrepareNamed(queryStr)
	err = nstmt.Select(&ret, arg)
	if err != nil {
		log.Println(err)
		return nil, err
	}
	nstmt.Close()
	return ret, nil
}

// @Title getRegionss
// @Description retrieves the regions
// @Accept  application/json
// @Success 200 {array}    Regions
// @Resource /api/2.0
// @Router /api/2.0/regions [get]
func getRegionss(db *sqlx.DB) (interface{}, error) {
	ret := []Regions{}
	queryStr := "select *, concat('" + API_PATH + "regions/', name) as self"
	queryStr += " from regions"
	err := db.Select(&ret, queryStr)
	if err != nil {
		log.Println(err)
		return nil, err
	}
	return ret, nil
}

// @Title postRegions
// @Description enter a new regions
// @Accept  application/json
// @Param                 Body body     Regions   true "Regions object that should be added to the table"
// @Success 200 {object}    output_format.ApiWrapper
// @Resource /api/2.0
// @Router /api/2.0/regions [post]
func postRegions(payload []byte, db *sqlx.DB) (interface{}, error) {
	var v Regions
	err := json.Unmarshal(payload, &v)
	if err != nil {
		log.Println(err)
		return nil, err
	}
	sqlString := "INSERT INTO regions("
	sqlString += "name"
	sqlString += ",division"
	sqlString += ",created_at"
	sqlString += ") VALUES ("
	sqlString += ":name"
	sqlString += ",:division"
	sqlString += ",:created_at"
	sqlString += ")"
	result, err := db.NamedExec(sqlString, v)
	if err != nil {
		log.Println(err)
		return nil, err
	}
	return result, err
}

// @Title putRegions
// @Description modify an existing regionsentry
// @Accept  application/json
// @Param   id              path    int     true        "The row id"
// @Param                 Body body     Regions   true "Regions object that should be added to the table"
// @Success 200 {object}    output_format.ApiWrapper
// @Resource /api/2.0
// @Router /api/2.0/regions/{id}  [put]
func putRegions(name string, payload []byte, db *sqlx.DB) (interface{}, error) {
	var arg Regions
	err := json.Unmarshal(payload, &arg)
	arg.Name = name
	if err != nil {
		log.Println(err)
		return nil, err
	}
	sqlString := "UPDATE regions SET "
	sqlString += "name = :name"
	sqlString += ",division = :division"
	sqlString += ",created_at = :created_at"
	sqlString += " WHERE name=:name"
	result, err := db.NamedExec(sqlString, arg)
	if err != nil {
		log.Println(err)
		return nil, err
	}
	return result, err
}

// @Title delRegionsById
// @Description deletes regions information for a certain id
// @Accept  application/json
// @Param   id              path    int     false        "The row id"
// @Success 200 {array}    Regions
// @Resource /api/2.0
// @Router /api/2.0/regions/{id} [delete]
func delRegions(name string, db *sqlx.DB) (interface{}, error) {
	arg := Regions{}
	arg.Name = name
	result, err := db.NamedExec("DELETE FROM regions WHERE name=:name", arg)
	if err != nil {
		log.Println(err)
		return nil, err
	}
	return result, err
}
