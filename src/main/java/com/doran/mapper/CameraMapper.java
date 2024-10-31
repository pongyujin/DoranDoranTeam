package com.doran.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import com.doran.entity.Camera;

@Mapper
public interface CameraMapper {

	int cameraInsert(Camera camera);

	List<Camera> getImage(Camera camera);

	@Select("SELECT * FROM camera WHERE imgNum = #{imgNum}")
    Camera selectCameraByImgNum(int imgNum);


	
}
